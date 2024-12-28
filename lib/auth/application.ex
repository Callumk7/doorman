defmodule Auth.Application do
  use Application

  def start(_type, _args) do
    children = [
      {Registry, keys: :unique, name: Auth.TenantRegistry},
      {Auth.Tenants.Manager, []}
    ]

    opts = [strategy: :one_for_one, name: Auth.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
