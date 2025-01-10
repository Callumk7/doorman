defmodule Auth.Repo.Migrations.AddKeysForTenants do
  use Ecto.Migration

  def change do
    alter table(:tenants) do
      add :api_key, :string, null: false
      add :secret_key, :string, null: false
    end

    create unique_index(:tenants, [:api_key])
  end
end
