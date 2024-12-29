defmodule Auth.Storage.Behaviour do
  @type user :: %{
          id: String.t(),
          tenant_id: String.t(),
          username: String.t(),
          email: String.t(),
          password_hash: String.t()
        }

  @callback create_user(user()) :: {:ok, user()} | {:error, term()}
  @callback find_user_by_username(String.t(), String.t()) :: {:ok, user()} | {:error, :not_found}
  @callback update_user(user()) :: {:ok, user()} | {:error, term()}
  @callback delete_user(String.t()) :: :ok | {:error, term()}
end
