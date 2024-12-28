defmodule Auth.Authentication.PasswordManager do
  @hash_rounds 12

  def hash_password(password) do
    Argon2.hash_pwd_salt(password, rounds: @hash_rounds)
  end

  def verify_password(plain_password, stored_hash) do
    Argon2.verify_pass(plain_password, stored_hash)
  end

  def generate_reset_token do
    :crypto.strong_rand_bytes(32) |> Base.url_encode64(padding: false)
  end
end
