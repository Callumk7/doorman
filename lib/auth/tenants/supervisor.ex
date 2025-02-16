defmodule Auth.Tenants.Supervisor do
  use DynamicSupervisor

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_tenant(tenant_id) do
    DynamicSupervisor.start_child(__MODULE__, {Auth.Tenants.Server, tenant_id})
  end

  def stop_tenant(tenant_id) do
    case Registry.lookup(Auth.Tenants.Registry, tenant_id) do
      [{pid, _}] ->
        DynamicSupervisor.terminate_child(__MODULE__, pid)

      [] ->
        {:error, :not_found} # Probably doesn't need to be an error
    end
  end
end
