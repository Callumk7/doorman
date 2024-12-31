defmodule Auth.Repo.Migrations.CreateTenants do
  use Ecto.Migration

  def change do
    create table(:tenants) do
      add :name, :string, null: false
      add :slug, :string, null: false
      add :settings, :map

      timestamps()
    end

    create unique_index(:tenants, [:slug])
  end
end
