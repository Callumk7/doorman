defmodule Auth.Sessions.Cache do
  use GenServer
  alias Auth.{Repo, Sessions}

  # Client APIs
  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def create_session(user) do
    GenServer.call(__MODULE__, {:create_session, user})
  end

  def verify_session(token) do
    GenServer.call(__MODULE__, {:verify_session, token})
  end

  def terminate_session(token) do
    GenServer.cast(__MODULE__, {:terminate_session, token})
  end

  # Server Callbacks
  def init(_) do
    state = Sessions.Manager.list_active_sessions()
    {:ok, state}
  end

  def handle_call({:create_session, user}, _from, state) do
    session = Session.create_session(user)

    case session do
      {:ok, session} ->
        {:reply, Map.put(state, session.token, session)}

      {:error, changeset} ->
        state
    end
  end
end
