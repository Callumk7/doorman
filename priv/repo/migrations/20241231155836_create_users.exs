defmodule Auth.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string, null: false
      add :password_hash, :string
      add :tenant_id, references(:tenants, on_delete: :delete_all)
      add :active, :boolean, default: true

      timestamps()
    end

    create unique_index(:users, [:email, :tenant_id])
  end
end
