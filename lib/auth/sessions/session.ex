defmodule Auth.Sessions.Session do
  use Ecto.Schema
  import Ecto.Changeset

  schema "sessions" do
    field(:token, :string)
    field(:expires_at, :utc_datetime)
    belongs_to(:user, Auth.Accounts.User)

    timestamps()
  end

  def changeset(session, attrs) do
    session
    |> cast(attrs, [:token, :user_id, :expires_at])
    |> validate_required([:token, :user_id, :expires_at])
    |> unique_constraint(:token)
  end
end
