import Config

config :auth_server,
  ecto_repos: [Auth.Database.Repo]

config :auth_server, Auth.Database.Repo,
  database: Path.expand("../db/state.db", Path.dirname(__ENV__.file))

