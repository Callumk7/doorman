defmodule Auth.Authentication.UserManager do
  alias Auth.Authentication.PasswordManager
  alias Auth.Accounts.User
  alias Auth.Database.UserRepo

  import Ecto.Query

  def create_user(tenant_id, username, email, password) do
    %User{}
    |> User.registration_changeset(%{
      tenant_id: tenant_id,
      username: username,
      email: email,
      password_hash: PasswordManager.hash_password(password)
    })
    |> UserRepo.insert()
  end

  def authenticate(tenant_id, username, password) do
    query = from(u in User, where: u.tenant_id == ^tenant_id and u.username == ^username)

    case UserRepo.one(query) do
      nil ->
        {:error, :user_not_found}

      user ->
        if PasswordManager.verify_password(password, user.password_hash) do
          {:ok, user}
        else
          {:error, :invalid_credentials}
        end
    end
  end

  def get_user_by_email(email) do
    UserRepo.get_by(User, email: email)
  end
end
