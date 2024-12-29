defmodule Auth.Tenants.Manager do
  use GenServer

  # By providing a name, we are making this process unique
  def start_link(opts \\ []) do
    IO.puts("Tenants.Manager start_link is running")
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_opts) do
    IO.puts("Tenants.Manager init is running")
  end
end
