defmodule Auth.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field(:email, :string)
    field(:password_hash, :string)
    field(:password, :string, virtual: true)
    field(:active, :boolean, default: true)
    belongs_to(:tenant, Auth.Tenants.Tenant)
    has_many(:sessions, Auth.Sessions.Session)

    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :password, :tenant_id, :active])
    |> validate_required([:email, :password, :tenant_id])
    |> unique_constraint([:email, :tenant_id])
    |> put_password_hash()
  end

  defp put_password_hash(%{valid?: true, changes: %{password: password}} = changeset) do
    put_change(changeset, :password_hash, hash_pwd)
  end
end
