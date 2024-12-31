defmodule Auth.Tenant.Server do
  @moduledoc """
  The main server for handling each tenant.
  Servers are created using Auth.Tenant.Manager.
  """
  use GenServer
  require Logger
  alias Auth.Tenant.Manager

  def start_link(tenant) do
    GenServer.start_link(__MODULE__, tenant, name: via_tuple(tenant.id))
  end

  def init(tenant) do
    # State is loaded by the tenant manager
    {:ok, tenant}
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
