defmodule Auth.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder,
           only: [:id, :email, :external_id, :role, :tenant_id, :inserted_at, :updated_at]}
  schema "users" do
    field(:email, :string)
    field(:external_id, :string)
    field(:password_hash, :string)
    field(:password, :string, virtual: true)
    field(:role, :string, default: "user")
    belongs_to(:tenant, Auth.Tenants.Tenant)
    has_many(:refresh_tokens, Auth.Accounts.RefreshToken)

    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :external_id, :password, :tenant_id, :role])
    |> validate_required([:email, :password, :tenant_id])
    |> validate_inclusion(:role, ["admin", "user"])
    |> unique_constraint([:email, :tenant_id])
    |> unique_constraint([:external_id, :tenant_id])
    |> put_password_hash()
  end

  def update_changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :external_id, :password, :role])
    |> validate_inclusion(:role, ["admin", "user"])
    |> unique_constraint([:email, :tenant_id])
    |> unique_constraint([:external_id, :tenant_id])
    |> put_password_hash()
  end

  defp put_password_hash(%{valid?: true, changes: %{password: password}} = changeset) do
    put_change(changeset, :password_hash, Auth.Accounts.PasswordManager.hash_password(password))
  end

  defp put_password_hash(changeset), do: changeset
end
