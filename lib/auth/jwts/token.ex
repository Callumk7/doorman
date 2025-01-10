defmodule Auth.Jwts.Token do
  use Joken.Config

  @impl true
  def token_config do
    fifteen_minutes = 60 * 15

    default_claims(default_exp: fifteen_minutes)
    |> add_claim("tenant", nil, &(&1 != nil))
  end

  def generate_refresh_token do
    :crypto.strong_rand_bytes(32) |> Base.url_encode64(padding: false)
  end
end
