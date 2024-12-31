defmodule Auth.Tenant.Manager do
  require Logger
  alias Auth.Tenant
  import Ecto.Query

  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_) do
    send(self(), :load_tenants)
    {:ok, %{tenants: %{}}}
  end

  @impl true
  def handle_info(:load_tenants, state) do
    tenants = load_tenants_from_db()

    new_state = load_tenant_servers(tenants, state)
    {:noreply, new_state}
  end

  defp load_tenant_servers(tenants, state) do
    Enum.reduce(tenants, state, fn tenant, acc ->
      case start_tenant_server(tenant) do
        {:ok, pid} ->
          put_in(acc.tenants[tenant.id], %{pid: pid, config: tenant.config})

        {:error, reason} ->
          Logger.error("Failed to start tenant #{tenant.id}: #{inspect(reason)}")
      end
    end)
  end

  defp load_tenants_from_db do
    Auth.Database.Repo.all("""
      SELECT id, config, status
      FROM tenants
      WHERE status = 'active'
    """)
  end

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
         |> Auth.Database.Repo.insert() do
      {:ok, tenant} ->
        {:ok, tenant.id}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def get_tenant_data(tenant_id) do
    Auth.Database.Repo.get_by(Tenant, id: tenant_id)
  end

  def delete_tenant(tenant_id) do
    Auth.Database.Repo.get_by(Tenant, id: tenant_id)
    |> Ecto.Changeset.change(%{status: :deleted, deleted_at: NaiveDateTime.utc_now()})
    |> Auth.Database.Repo.update()
  end

  def list_tenants(status \\ nil) do
    query =
      if status do
        from(t in Tenant, where: t.status == ^status)
      else
        Tenant
      end

    Auth.Database.Repo.all(query)
  end

  def activate_tenant(tenant_id) do
    case Auth.Database.Repo.get_by(Tenant, id: tenant_id)
         |> Ecto.Changeset.change(%{
           status: :active,
           last_active_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
         })
         |> Auth.Database.Repo.update() do
      {:ok, _tenant} ->
        start_tenant_server(tenant_id)

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def suspend_tenant(tenant_id, reason \\ nil) do
    Auth.Database.Repo.get_by(Tenant, id: tenant_id)
    |> Ecto.Changeset.change(%{
      status: :suspended,
      suspended_at: NaiveDateTime.utc_now(),
      metadata: %{suspension_reason: reason}
    })
    |> Auth.Database.Repo.update()
  end

  defp start_tenant_server(tenant_id) do
    Auth.Tenant.Supervisor.start_tenant(tenant_id)
  end
end
