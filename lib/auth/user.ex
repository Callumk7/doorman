defmodule Auth.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field(:tenant_id, :string)
    field(:username, :string)
    field(:email, :string)
    field(:password_hash, :string)
    field(:confirmed, :boolean)
    field(:locked, :boolean)
    field(:failed_attempts, :integer)
    field(:last_login, :utc_datetime)
    field(:magic_link_token, :string)
    field(:magic_link_token_expires_at, :utc_datetime)
    field(:password_reset_token, :string)
    field(:password_reset_token_expires_at, :utc_datetime)
    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:tenant_id, :username, :email, :password_hash])
    |> validate_required([:tenant_id, :username, :email, :password_hash])
    |> validate_format(:email, ~r/@/)
    |> unique_constraint([:username, :tenant_id])
  end

  def registration_changeset(user, attrs) do
    user
    |> changeset(attrs)
    |> validate_length(:password_hash, min: 6)
  end
end
