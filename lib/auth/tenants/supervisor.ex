defmodule Auth.Tenants.Supervisor do
  use DynamicSupervisor

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_tenant(tenant_id) do
    spec = {Auth.Tenants.Server, tenant_id: tenant_id}
    DynamicSupervisor.start_child(__MODULE__, spec)
  end

  def get_tenant(tenant_id) do
    case Registry.lookup(Auth.TenantRegistry, tenant_id) do
      [{pid, _}] -> {:ok, pid}
      [] -> start_tenant(tenant_id)
    end
  end
end
