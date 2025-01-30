defmodule Auth.Plugs.Authenticate do
  alias Auth.Jwts.Token
  import Plug.Conn

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    with {:ok, token} <- extract_access_token(conn),
         {:ok, claims} <- verify_token(token) do
      conn
      |> assign(:current_user_id, claims["sub"])
      |> assign(:current_tenant_id, claims["tenant"])
      |> assign(:current_user_role, claims["role"])
    else
      {:error, reason} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(401, Jason.encode!(%{error: error_message(reason)}))
        |> halt()
    end
  end

  defp extract_access_token(conn) do
    conn = fetch_cookies(conn)
    case conn.req_cookies["access_token"] do
      nil ->
        {:error, :missing_token}

      token when is_binary(token) ->
        {:ok, token}

      _ ->
        {:error, :invalid_token_format}
    end
  end

  # Using the extract_access_token() function above instead than a bearer token
  # defp extract_token(conn) do
  #   case get_req_header(conn, "authorization") do
  #     ["Bearer " <> token] -> {:ok, token}
  #     _ -> {:error, :missing_token}
  #   end
  # end

  defp verify_token(token) do
    case Token.verify_and_validate(token) do
      {:ok, claims} -> {:ok, claims}
      {:error, _reason} -> {:error, :invalid_token}
    end
  end

  defp error_message(:missing_token) do
    "Authentication token is missing"
  end

  defp error_message(:invalid_token) do
    "Authentication token is invalid or expired"
  end
end
