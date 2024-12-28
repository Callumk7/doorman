defmodule Auth.Server do
  use GenServer

  @impl GenServer
  def init(_) do
    {:ok, %Auth.Credentials{}}
  end

  # Sync operations
  @impl GenServer
  def handle_call({:add_credentials, username, password_hash}, _from, state) do
    new_state = Auth.Credentials.add_credentials(state, username, password_hash)

    {:reply, {username, password_hash}, new_state}
  end

  @impl GenServer
  def handle_call({:get_entry, id}, _from, state) do
    entry = Map.get(state.entries, id)

    {:reply, entry, state}
  end

  # Asynchronous operations
  @impl GenServer
  def handle_cast({:update_password, id, new_password}, state) do
    new_state = Auth.Credentials.update_password(state, id, new_password)
    {:noreply, new_state}
  end

  # Client API
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def add_credentials(server, username, password_hash) do
    GenServer.call(server, {:add_credentials, username, password_hash})
  end

  def get_entry(server, id) do
    GenServer.call(server, {:get_entry, id})
  end

  def update_password(server, id, new_password) do
    GenServer.cast(server, {:update_password, id, new_password})
  end
end
