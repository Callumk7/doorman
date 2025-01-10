defmodule Auth.Tenants.Tenant do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tenants" do
    field(:name, :string)
    field(:slug, :string)
    field(:settings, :map)
    field(:api_key, :string)
    field(:secret_key, :string)
    has_many(:users, Auth.Accounts.User)

    timestamps()
  end

  def changeset(tenant, attrs) do
    tenant
    |> cast(attrs, [
      :name,
      :slug,
      :settings
    ])
    |> validate_required([:name, :slug])
    |> unique_constraint(:slug)
  end
end
