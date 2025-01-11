defmodule Auth.Plugs.VerifyTenant do
  import Plug.Conn

  def init(opts), do: opts

  def call(%{assigns: %{current_tenant_id: tenant_id}} = conn, _opts) do
    %{"tenant_id" => tenant_param} = conn.params

    if tenant_param && tenant_id == String.to_integer(tenant_param) do
      conn
    else
      conn
      |> put_application_json()
      |> send_resp(403, Jason.encode!(%{error: "Access to this tenant is forbidden"}))
      |> halt()
    end
  end

  def call(conn, _opts) do
    conn
    |> put_application_json()
    |> send_resp(401, Jason.encode!(%{error: "Authentication required"}))
  end

  defp put_application_json(conn) do
    put_resp_content_type(conn, "application/json")
  end
end
