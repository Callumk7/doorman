defmodule Auth.Database.Repo do
  use Ecto.Repo, otp_app: :auth_server, adapter: Ecto.Adapters.SQLite3

  def get_tenant_by_id(tenant_id) do
    Auth.Database.Repo.get_by(Tenant, id: tenant_id)
  end
end
