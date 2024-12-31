defmodule Auth.Database.Repo.Migrations.CreateTables do
  use Ecto.Migration

  def change do
    create table(:tenants) do
      add :name, :string, nil: false
      add :status, :string
      add :created_at, :naive_datetime
      add :last_active_at, :naive_datetime
      add :suspended_at, :naive_datetime
      add :deleted_at, :naive_datetime
      add :metadata, :map, default: %{}
      timestamps()
    end

    create table(:users) do
      add :tenant_id, :integer
      add :username, :string
      add :email, :string
      add :password_hash, :string
      add :confirmed, :boolean
      add :locked, :boolean
      add :failed_attempts, :integer
      add :last_login, :utc_datetime
      add :magic_link_token, :string
      add :magic_link_token_expires_at, :utc_datetime
      add :password_reset_token, :string
      add :password_reset_token_expires_at, :utc_datetime
      timestamps()
    end
  end
end
