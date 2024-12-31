defmodule Auth.Tenants.Supervisor do
  use DynamicSupervisor

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_tenant(tenant_id) do
    DynamicSupervisor.start_child(__MODULE__, {Auth.Tenants.Server, tenant_id})
  end
end
