defmodule Auth.Tenants.Manager do
  alias Auth.Accounts.User
  alias Auth.Repo
  alias Auth.Tenants.Tenant

  import Ecto.Query

  @doc """
  Creates a tenant entry in the database.
  """
  def create_tenant(attrs) do
    %Tenant{}
    |> Tenant.changeset(attrs)
    |> Tenant.put_api_key()
    |> Tenant.put_secret_key()
    |> Repo.insert()
  end

  def get_tenant_with_users(tenant_id) do
    case Repo.get(Tenant, tenant_id) |> Repo.preload(:users) do
      nil -> {:error, :tenant_not_found}
      tenant -> tenant
    end
  end

  def list_users(tenant_id) do
    User
    |> where(tenant_id: ^tenant_id)
    |> Repo.all()
  end

  def get_tenant!(id), do: Repo.get!(Tenant, id)
  def get_tenant_by_slug(slug), do: Repo.get_by(Tenant, slug: slug)
end
