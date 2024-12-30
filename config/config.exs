import Config

config :auth_server,
  ecto_repos: [Auth.Database.UserRepo, Auth.Database.TenantRepo]

config :auth_server, Auth.Database.UserRepo,
  database: Path.expand("../db/users.db", Path.dirname(__ENV__.file))

config :auth_server, Auth.Database.TenantRepo,
  database: Path.expand("../db/tenants.db", Path.dirname(__ENV__.file))
