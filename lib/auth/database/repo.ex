defmodule Auth.Database.Repo do
  use Ecto.Repo, otp_app: :auth_server, adapter: Ecto.Adapters.SQLite3
end
