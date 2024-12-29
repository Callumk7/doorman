defmodule Auth.Application do
  use Application

  def start(_type, _args) do
    IO.puts("Starting Auth Application")

    children = [
      Auth.Database.Repo,
      {Registry, keys: :unique, name: Auth.TenantRegistry},
      Auth.Tenants.Supervisor,
      Auth.ProcessMonitor
    ]

    opts = [strategy: :one_for_one, name: Auth.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
