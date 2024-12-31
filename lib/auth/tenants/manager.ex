defmodule Auth.Tenants.Manager do
  alias Auth.Repo
  alias Auth.Tenants.Tenant

  def create_tenant(attrs) do
    %Tenant{}
    |> Tenant.changeset(attrs)
    |> Repo.insert()
  end

  def get_tenant!(id), do: Repo.get!(Tenant, id)
  def get_tenant_by_slug(slug), do: Repo.get_by(Tenant, slug: slug)
end
