defmodule Auth.Repo.Migrations.AddExternalIdToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :external_id, :string
    end

    create unique_index(:users, [:external_id, :tenant_id], 
      name: :users_external_id_tenant_id_unique_index,
      where: "external_id IS NOT NULL"
    )
  end
end
