defmodule Auth.Tenants.Server do
  require Logger
  use GenServer

  def start_link(opts) do
    tenant_id = Keyword.fetch!(opts, :tenant_id)
    GenServer.start_link(__MODULE__, tenant_id, name: via_tuple(tenant_id))
  end

  def init(tenant_id) do
    {:ok, %{id: tenant_id, users: [], created_at: NaiveDateTime.utc_now()}}
  end

  # Public API
  def create_user(tenant_id, username, email, password) do
    GenServer.call(via_tuple(tenant_id), {:create_user, username, email, password})
  end

  def authenticate(tenant_id, username, password) do
    GenServer.call(via_tuple(tenant_id), {:authenticate, username, password})
  end

  # Sync
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
