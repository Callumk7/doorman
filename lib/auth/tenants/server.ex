defmodule Auth.Tenants.Server do
  use GenServer
  alias Auth.{Accounts}

  # Client API
  def start_link(tenant_id) do
    name = via_tuple(tenant_id)
    GenServer.start_link(__MODULE__, tenant_id, name: name)
  end

  def get_active_users(tenant_id) do
    GenServer.call(via_tuple(tenant_id), :get_active_users)
  end

  def add_user(tenant_id, user) do
    GenServer.cast(via_tuple(tenant_id), {:add_user, user})
  end

  def remove_user(tenant_id, user_id) do
    GenServer.cast(via_tuple(tenant_id), {:remove_user, user_id})
  end

  # Server Callback implementation
  @impl true
  def init(tenant_id) do
    {:ok, tenant_id}
  end

  @impl true
  def handle_call(:get_active_users, _, state) do
    {:reply, state.users, state}
  end

  @impl true
  def handle_cast({:add_user, user}, state) do
    {:noreply, %{state | users: [user | state.users]}}
  end

  @impl true
  def handle_cast({:remove_user, user_id}, state) do
    users = Enum.reject(state.users, &(&1.id == user_id))
    {:noreply, %{state | users: users}}
  end

  defp via_tuple(tenant_id) do
    {:via, Registry, {Auth.TenantRegistry, tenant_id}}
  end
end
