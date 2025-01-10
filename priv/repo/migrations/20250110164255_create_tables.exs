defmodule Auth.Repo.Migrations.CreateTables do
  use Ecto.Migration

  def change do
    create table(:tenants) do
      add :name, :string, null: false
      add :slug, :string, null: false
      add :api_key, :string
      add :secret_key, :string

      timestamps()
    end

    create unique_index(:tenants, [:slug, :api_key])

    create table(:users) do
      add :email, :string, null: false
      add :password_hash, :string, null: false
      add :tenant_id, references(:tenants, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:users, [:email, :tenant_id])

    create table(:refresh_tokens) do
      add :token, :string, null: false
      add :user_id, references(:users, on_delete: :delete_all)
      add :expires_at, :utc_datetime, null: false

      timestamps()
    end

    create unique_index(:refresh_tokens, [:token])
  end
end
