defmodule Auth.Router do
  use Plug.Router

  @cookie_options [
    http_only: true,
    secure: true,
    same_site: "Strict"
  ]

  # 1 hour
  @access_token_max_age 60 * 60
  # 30 days
  @refresh_token_max_age 30 * 24 * 60 * 60

  plug(CORSPlug,
    origin: ["http://localhost:5173"],
    methods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    headers: ["Authorization", "Content-Type", "Accept"],
    expose_headers: ["Authorization"],
    credentials: true
  )

  plug(Plug.Logger)
  plug(:match)
  plug(Plug.Parsers, parsers: [:json], pass: ["application/json"], json_decoder: Jason)
  plug(:dispatch)

  post "/api/register" do
    case Auth.Accounts.Manager.create_user(conn.body_params) do
      {:ok, user} ->
        {:ok, tokens} = Auth.Accounts.Manager.create_tokens(user)

        conn
        |> set_auth_cookies(tokens)
        |> send_json(200, %{message: "Registration Successful", user_id: user.id})

      {:error, changeset} ->
        send_json(conn, 422, %{errors: format_errors(changeset)})
    end
  end

  post "/api/login" do
    %{"email" => email, "password" => password, "tenant_id" => tenant_id} = conn.body_params

    case Auth.Accounts.Manager.authenticate(email, password, tenant_id) do
      {:ok, user} ->
        {:ok, tokens} = Auth.Accounts.Manager.create_tokens(user)

        conn
        |> set_auth_cookies(tokens)
        |> send_json(200, %{message: "Login Successful", user_id: user.id})

      {:error, :invalid_credentials} ->
        conn |> send_json(401, %{errror: "Invalid Credentials"})
    end
  end

  post "/api/refresh" do
    %{"refresh_token" => refresh_token} = conn.body_params

    case Auth.Accounts.Manager.refresh_tokens(refresh_token) do
      {:ok, tokens} ->
        conn
        |> set_auth_cookies(tokens)
        |> send_json(200, %{message: "Refresh Successful"})

      {:error, _} ->
        send_json(conn, 401, %{error: "Invalid refresh token"})
    end
  end

  post "api/logout" do
    conn = fetch_cookies(conn)

    case conn.req_cookies["refresh_token"] do
      nil ->
        send_json(conn, 404, %{error: "Token not found"})

      token when is_binary(token) ->
        case Auth.Accounts.Manager.revoke_refresh_token(token) do
          {:ok, _} ->
            conn
            |> delete_resp_cookie(
              "access_token",
              @cookie_options
            )
            |> delete_resp_cookie(
              "refresh_token",
              @cookie_options
            )
            |> send_resp(204, "Success")

          {:error, _} ->
            send_json(conn, 404, %{error: "Token not found"})
        end

      _ ->
        send_json(conn, 404, %{error: "Incorrect token format"})
    end
  end

  forward("/api/protected", to: Auth.Router.Protected)

  match _ do
    send_resp(conn, 404, "oops")
  end

  defp send_json(conn, status, body) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, Jason.encode!(body))
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end

  defp set_auth_cookies(conn, tokens) do
    conn
    |> put_resp_cookie(
      "access_token",
      tokens.access_token,
      Keyword.merge(@cookie_options, max_age: @access_token_max_age)
    )
    |> put_resp_cookie(
      "refresh_token",
      tokens.refresh_token,
      Keyword.merge(@cookie_options, max_age: @refresh_token_max_age)
    )
  end
end
