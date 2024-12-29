defmodule Auth.Tenants.AuthService do
  def register_user(tenant_id, username, email, password) do
    # Ensure that the tenant exists, otherwise create it
    {:ok, _pid} = Auth.Tenants.Supervisor.get_tenant(tenant_id)

    # Create the user
    Auth.Tenants.Server.create_user(tenant_id, username, email, password)
  end

  def authenticate(tenant_id, username, password) do
    case Auth.Tenants.Supervisor.get_tenant(tenant_id) do
      {:ok, _pid} ->
        Auth.Tenants.Server.authenticate(tenant_id, username, password)

      {:error, reason} ->
        {:error, reason}
    end
  end
end
