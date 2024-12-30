defmodule Auth.Database.TenantRepo.Migrations.CreateTables do
  use Ecto.Migration

  def change do
    create table(:tenants) do
      add :name, :string 
      add :status, :string 
      add :max_users, :integer, default: 100
      add :current_user_count, :integer, default: 0
      add :created_at, :naive_datetime
      add :last_active_at, :naive_datetime
      add :suspended_at, :naive_datetime
      add :deleted_at, :naive_datetime
      add :metadata, :map
      timestamps()
    end
  end
end
