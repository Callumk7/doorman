defmodule Auth.Database.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :tenant_id, :string, null: false
      add :username, :string, null: false
      add :email, :string, null: false
      add :password_hash, :string, null: false
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

    create unique_index(:users, [:username, :tenant_id])
    create index(:users, [:email])
  end
end
