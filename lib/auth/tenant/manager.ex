defmodule Auth.Tenant.Manager do
  alias Auth.Tenant
  import Ecto.Query

  @doc """
  Create a tenant in the database, but do not start a process.
  """
  def create_tenant(name, opts \\ %{}) do
    attrs =
      Map.merge(
        %{
          name: name,
          status: :pending,
          created_at: NaiveDateTime.utc_now()
        },
        opts
      )

    case %Tenant{}
         |> Tenant.changeset(attrs)
         |> Auth.Database.TenantRepo.insert() do
      {:ok, tenant} ->
        {:ok, tenant.id}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def get_tenant(tenant_id) do
    Auth.Database.TenantRepo.get_by(Tenant, id: tenant_id)
  end

  def delete_tenant(tenant_id) do
    Auth.Database.TenantRepo.get_by(Tenant, id: tenant_id)
    |> Ecto.Changeset.change(%{status: :deleted, deleted_at: NaiveDateTime.utc_now()})
    |> Auth.Database.TenantRepo.update()
  end

  def list_tenants(status \\ nil) do
    query =
      if status do
        from(t in Tenant, where: t.status == ^status)
      else
        Tenant
      end

    Auth.Database.TenantRepo.all(query)
  end

  def activate_tenant(tenant_id) do
    case Auth.Database.TenantRepo.get_by(Tenant, id: tenant_id)
         |> Ecto.Changeset.change(%{
           status: :active,
           last_active_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
         })
         |> Auth.Database.TenantRepo.update() do
      {:ok, tenant} ->
        Auth.Tenant.Server.start_link(tenant)

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def suspend_tenant(tenant_id, reason \\ nil) do
    Auth.Database.TenantRepo.get_by(Tenant, id: tenant_id)
    |> Ecto.Changeset.change(%{
      status: :suspended,
      suspended_at: NaiveDateTime.utc_now(),
      metadata: %{suspension_reason: reason}
    })
    |> Auth.Database.TenantRepo.update()
  end
end
