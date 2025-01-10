defmodule Auth.Accounts.RefreshToken do
  use Ecto.Schema
  import Ecto.Changeset

  schema "refresh_tokens" do
    field(:token, :string)
    field(:expires_at, :utc_datetime)
    belongs_to(:user, Auth.Accounts.User)

    timestamps()
  end

  def changeset(refresh_token, attrs) do
    refresh_token
      |> cast(attrs, [:token, :user_id, :expires_at])
      |> validate_required([:token, :user_id, :expires_at])
      |> unique_constraint(:token)
  end
end
