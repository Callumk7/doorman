defmodule Auth.Application do
  use Application

  def start(_type, _args) do
    IO.puts("Starting Auth Application")

    children = [
      Auth.Database.UserRepo,
      Auth.Database.TenantRepo,
      {Registry, keys: :unique, name: Auth.TenantRegistry},
      Auth.Tenant.Supervisor,
      Auth.ProcessMonitor
    ]

    opts = [strategy: :one_for_one, name: Auth.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
