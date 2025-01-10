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

  def put_api_key(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true} ->
        put_change(changeset, :api_key, generate_key())

      _ ->
        changeset
    end
  end

  def put_secret_key(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true} ->
        put_change(changeset, :secret_key, generate_key())

      _ ->
        changeset
    end
  end

  defp generate_key do
    :crypto.strong_rand_bytes(32) |> Base.encode64(padding: false)
  end
end
