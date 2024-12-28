defmodule Auth.Accounts.MagicLinkManager do
  def generate_magic_link_token do
    :crypto.strong_rand_bytes(32) |> Base.url_encode64(padding: false)
  end

  def create_magic_link(user, expires_in \\ :timer.hours(1)) do
    token = generate_magic_link_token()

    expires_at =
      NaiveDateTime.utc_now()
      |> NaiveDateTime.add(expires_in, :millisecond)

    %{user | magic_link_token: token, magic_link_expires_at: expires_at}
  end

  def validate_magic_link(user, token) do
    cond do
      user.magic_link_token != token ->
        {:error, :invalid_token}

      NaiveDateTime.compare(NaiveDateTime.utc_now(), user.magic_link_expires_at) == :gt ->
        {:error, :token_expired}

      true ->
        {:ok, user}
    end
  end
end
