defmodule Auth.Application do
  use Application

  def start(_type, _args) do
    IO.puts("Starting Auth Application")

    children = [
      Auth.Repo,
      {Bandit, plug: Auth.Router},
      # {Registry, keys: :unique, name: Auth.Tenants.Registry},
      # Auth.Tenants.Supervisor
    ]

    opts = [strategy: :one_for_one, name: Auth.Application]
    Supervisor.start_link(children, opts)
  end
end
