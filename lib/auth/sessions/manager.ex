defmodule Auth.Sessions do
  alias Auth.{Repo, Sessions.Session}

  def create_session(user) do
    %Session{}
    |> Session.changeset(%{
      token: generate_token(),
      user_id: user.id,
      expires_at: DateTime.utc_now() |> DateTime.add(24 * 3600, :second)
    })
    |> Repo.insert()
  end

  def verify_session(token) do
    case Repo.get_by(Session, token: token) do
      nil -> {:error, :invalid_token}
      session ->
        if DateTime.compare(session.expires_at, DateTime.utc_now()) == :gt do
          {:ok, session}
        else
          {:error, :expired_token}
        end
    end
  end

  defp generate_token do
    :crypto.strong_rand_bytes(32)
    |> Base.url_encode64(padding: false)
  end
end

