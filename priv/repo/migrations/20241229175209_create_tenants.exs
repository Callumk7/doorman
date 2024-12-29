defmodule Auth.Database.Repo.Migrations.CreateTenants do
  use Ecto.Migration

  def change do
   create table(:tenants) do
      add :name, :string
      add :status, :string
      add :max_users, :integer
      add :current_user_count, :integer
      
      add :created_at, :naive_datetime
      add :last_active_at, :naive_datetime
      add :suspended_at, :naive_datetime
      add :deleted_at, :naive_datetime
      
      add :metadata, :map

      timestamps()
    end

    create index(:tenants, [:status])
  end
end
