defmodule Auth.Repo.Migrations.CreateSessions do
  use Ecto.Migration

  def change do
    create table(:sessions) do
      add :token, :string, null: false
      add :user_id, references(:users, on_delete: :delete_all)
      add :expires_at, :utc_datetime

      timestamps()
    end

    create unique_index(:sessions, [:token])
  end
end
