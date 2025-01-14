defmodule Auth.Accounts.Manager do
  alias Auth.Repo
  alias Auth.Accounts.{User, RefreshToken}
  alias Auth.Jwts.Token

  def create_user(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def delete_user(user_id) do
    Repo.get_by!(User, id: user_id)
    |> Repo.delete()
  end

  def get_user(user_id) do
    Repo.get_by(User, id: user_id)
  end

  def get_user_role(user_id) do
    case Repo.get(User, user_id) do
      nil -> {:error, :user_not_found}
      {:ok, user} -> user.role
    end
  end

  def create_admin_user(attrs) do
    %User{}
    |> User.changeset(Map.put(attrs, :role, "admin"))
    |> Repo.insert()
  end

  def admin?(user), do: user.role == "admin"

  def authenticate(email, password, tenant_id) do
    user = Repo.get_by(User, email: email, tenant_id: tenant_id)

    with %User{} <- user,
         true <- Auth.Accounts.PasswordManager.verify_password(password, user.password_hash) do
      {:ok, user}
    else
      _ -> {:error, :invalid_credentials}
    end
  end

  def create_tokens(user) do
    refresh_token = Token.generate_refresh_token()
    expires_at = DateTime.utc_now() |> DateTime.add(30, :day) |> DateTime.truncate(:second)

    {:ok, access_token, _claims} =
      Token.generate_and_sign(%{
        "sub" => user.id,
        "email" => user.email,
        "tenant" => user.tenant_id,
        "role" => user.role
      })

    Repo.insert(%RefreshToken{
      token: refresh_token,
      user_id: user.id,
      expires_at: expires_at
    })

    {:ok, %{access_token: access_token, refresh_token: refresh_token}}
  end

  def refresh_tokens(refresh_token) do
    now = DateTime.utc_now()

    case Repo.get_by(RefreshToken, token: refresh_token) do
      %RefreshToken{expires_at: expires_at} = token ->
        case DateTime.compare(expires_at, now) do
          :gt ->
            user = Repo.get!(User, token.user_id)
            Repo.delete!(token)
            create_tokens(user)

          _ ->
            {:error, :invalid_token}
        end

      nil ->
        {:error, :invalid_token}
    end
  end

  def revoke_refresh_token(refresh_token) do
    case Repo.get_by(RefreshToken, token: refresh_token) do
      %RefreshToken{} = token -> Repo.delete(token)
      nil -> {:error, :not_found}
    end
  end
end
