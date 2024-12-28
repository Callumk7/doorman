defmodule Auth.Authentication.UserManager do
  alias Auth.Accounts.User
  use GenServer

  def start_link(tenant_id) do
    GenServer.start_link(__MODULE__, tenant_id, name: via_tuple(tenant_id))
  end

  def init(tenant_id) do
    {:ok, %{tenant_id: tenant_id}}
  end

  def register_user(tenant_id, username, email, password) do
    password_hash = Auth.Authentication.PasswordManager.hash_password(password)

    user = %User{
      id: generate_user_id(),
      tenant_id: tenant_id,
      username: username,
      email: email,
      password_hash: password_hash
    }

    :mnesia.transaction(fn ->
      :mnesia.write(
        {:users, user.id, user.tenant_id, user.username, user.email, user.password_hash}
      )
    end)

    {:ok, user}
  end

  def authenticate(tenant_id, username, password) do
    :mnesia.transaction(fn ->
      case :mnesia.index_read(:users, username, 2) do
        [{:users, id, ^tenant_id, ^username, email, stored_hash}] ->
          if Auth.Authentication.PasswordManager.verify_password(password, stored_hash) do
            {:ok,
             %User{
               id: id,
               tenant_id: tenant_id,
               username: username,
               email: email
             }}
          else
            {:error, :invalid_credentials}
          end

        _ ->
          {:error, :user_not_found}
      end
    end)
  end

  defp generate_user_id do
    :crypto.strong_rand_bytes(16) |> Base.encode64()
  end

  defp via_tuple(tenant_id) do
    {:via, Registry, {Auth.Tenants.Registry, tenant_id}}
  end
end
