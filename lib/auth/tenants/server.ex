defmodule Auth.Tenants.Server do
  use GenServer

  # Client API
  def start_link(tenant_id) do
    GenServer.start_link(__MODULE__, tenant_id, name: via_tuple(tenant_id))
  end

  def add_user(tenant_id, {name, email, password}) do
    GenServer.cast(via_tuple(tenant_id), {:add_user, {name, email, password}})
  end

  def remove_user(tenant_id, user_id) do
    GenServer.cast(via_tuple(tenant_id), {:remove_user, user_id})
  end

  def issue_token(tenant_id, {email, password}) do
    GenServer.call(via_tuple(tenant_id), {:issue_token, {email, password}})
  end

  def verify_token(tenant_id, token) do
    GenServer.call(via_tuple(tenant_id), {:verify_token, token})
  end

  # Server Callback implementation
  @impl true
  def init(tenant_id) do
    IO.puts("Starting tenant server with id: #{tenant_id}")
    {:ok, {tenant_id, nil}, {:continue, :init}}
  end

  @impl true
  def handle_continue(:init, {tenant_id, nil}) do
    tenant_state = Auth.Tenants.Manager.get_tenant_with_users(tenant_id)
    {:noreply, tenant_state}
  end

  # TODO: new_user should probably just be the fields that it expects?
  # Or is that going to be handled by the implementation
  @impl true
  def handle_cast({:add_user, {name, email, password}}, state) do
    case Auth.Accounts.Manager.create_user(%{name: name, email: email, password: password}) do
      {:ok, user} ->
        {:noreply, %{state | users: update_in(state.users[user.id], fn _ -> user end)}}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  @impl true
  def handle_cast({:remove_user, user_id}, state) do
    users = Enum.reject(state.users, &(&1.id == user_id))
    {:noreply, %{state | users: users}}
  end

  def handle_call({:issue_token, {email, password}}, state) do
    # handle issuing token
    claims = %{"email" => email, "password" => password}
    token = Auth.Jwts.Token.generate_and_sign!(claims)
    {:reply, token, state}
  end

  def handle_call({:verify_token, token}, state) do
    # handle verifying token token
    case Auth.Jwts.Token.verify_and_validate(token) do
      {:ok, claims} ->
        {:reply, claims, state}

      _ ->
        {:reply, {:error, :unauthorized}, state}
    end
  end

  defp via_tuple(tenant_id) do
    {:via, Registry, {Auth.Tenants.Registry, tenant_id}}
  end
end
