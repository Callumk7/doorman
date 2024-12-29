defmodule Auth.ProcessMonitor do
  use GenServer
  require Logger

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    # Initial state with process tracking
    {:ok,
     %{
       total_processes: 0,
       crashed_processes: 0,
       process_history: %{}
     }, {:continue, :monitor}}
  end

  def handle_continue(:monitor, state) do
    # Start monitoring
    :timer.send_interval(5000, :check_processes)
    {:noreply, state}
  end

  def handle_info(:check_processes, state) do
    # Get current process count
    process_count = :erlang.system_info(:process_count)

    # Log process information
    Logger.info("Process Count: #{process_count}")

    {:noreply, %{state | total_processes: process_count}}
  end

  # Track process crashes
  def handle_info({:DOWN, _ref, :process, pid, reason}, state) do
    Logger.error("Process Crashed",
      pid: inspect(pid),
      reason: inspect(reason)
    )
    # WARN: The above might not log the pid or reason

    updated_state = update_in(state.crashed_processes, &(&1 + 1))
    {:noreply, updated_state}
  end
end
