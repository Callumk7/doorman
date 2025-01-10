defmodule AuthServer.MixProject do
  use Mix.Project

  def project do
    [
      app: :auth_server,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Auth.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:argon2_elixir, "~> 4.0"},
      {:ecto_sql, "~> 3.10"},
      {:postgrex, ">= 0.0.0"},
      {:bandit, "~> 1.0"},
      {:joken, "~> 2.6"},
      {:jason, "~> 1.4"}
    ]
  end
end
