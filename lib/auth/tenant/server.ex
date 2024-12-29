defmodule Auth.Tenant.Server do
  alias Auth.Tenant.Manager
  require Logger
  use GenServer

  def start_link(opts) do
    tenant = Keyword.fetch!(opts, :tenant)
    GenServer.start_link(__MODULE__, tenant, name: via_tuple(tenant.id))
  end

  # TODO: This is the bit that is breaking the flow.. Need to not return stop for pending
  def init(tenant) do
    case tenant.status do
      :active ->
        {:ok,
         %{
           id: tenant.id,
           name: tenant.name,
           status: :active,
           users: [],
           max_users: tenant.max_users
         }}

      :pending ->
        {:stop, :tenant_not_activated}
    end
  end

  # Public API
  def create_user(tenant_id, username, email, password) do
    GenServer.call(via_tuple(tenant_id), {:create_user, username, email, password})
  end

  def authenticate(tenant_id, username, password) do
    GenServer.call(via_tuple(tenant_id), {:authenticate, username, password})
  end

  def activate(tenant_id) do
    GenServer.call(via_tuple(tenant_id), :activate)
  end

  def handle_call(:activate, _from, state) do
    case Manager.activate_tenant(state.id) do
      {:ok, _tenant} ->
        {:reply, :ok, %{state | status: :active}}

      {:error, reason} ->
        {:reply, {:error, reason}, state}
    end
  end

  def handle_call({:create_user, username, email, password}, _from, state) do
    case Auth.Authentication.UserManager.create_user(state.id, username, email, password) do
      {:ok, user} ->
        updated_state = update_in(state.users, fn users -> [user | users] end)
        {:reply, {:ok, user}, updated_state}

      {:error, changeset} ->
        {:reply, {:error, changeset}, state}
    end
  end

  def handle_call({:authenticate, username, password}, _from, state) do
    case Auth.Authentication.UserManager.authenticate(state.id, username, password) do
      {:ok, user} ->
        {:reply, {:ok, user}, state}

      {:error, reason} ->
        {:reply, {:error, reason}, state}
    end
  end

  defp via_tuple(tenant_id) do
    {:via, Registry, {Auth.TenantRegistry, tenant_id}}
  end
end
