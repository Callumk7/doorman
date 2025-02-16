import Config

if config_env() in [:dev, :test] do
  import_config ".env.exs"
end

config :auth_server, Auth.Repo,
  database: "auth_server_repo",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"

config :auth_server,
  ecto_repos: [Auth.Repo]
