defmodule Auth.Router.Protected do
  use Plug.Router

  plug(Auth.Plugs.Authenticate)
  plug(:match)
  plug(:dispatch)

  get "/me" do
    user_id = conn.assigns.current_user_id
    user = Auth.Accounts.Manager.get_user(user_id)

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!(user))
  end

  # Tenant specific routes
  post "/tenants" do
    case Auth.Tenants.Manager.create_tenant(conn.body_params) do
      {:ok, tenant} ->
        send_json(conn, 201, tenant)

      {:error, changeset} ->
        send_json(conn, 422, %{errors: format_errors(changeset)})
    end
  end

  get "/tenants/:tenant_id/users" do
    conn = Auth.Plugs.VerifyTenant.call(conn, [])

    unless conn.halted do
      users = Auth.Tenants.Manager.list_users(conn.assigns.current_tenant_id)

      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, Jason.encode!(users))
    else
      conn
    end
  end

  post "/admin/tenants" do
    unless conn.halted do
      case Auth.Tenants.Manager.create_tenant(conn.body_params) do
        {:ok, tenant} ->
          conn
          |> put_resp_content_type("application/json")
          |> send_resp(201, Jason.encode!(%{name: tenant.name, slug: tenant.slug}))

        {:error, changeset} ->
          conn
          |> put_resp_content_type("application/json")
          |> send_resp(422, Jason.encode!(%{errors: format_errors(changeset)}))
      end
    else
      conn
    end
  end

  match _ do
    send_resp(conn, 404, "Not found")
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
end
