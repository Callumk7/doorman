defmodule Auth.Storage.SqliteAdapter do
  @behaviour Auth.Storage.Behaviour

  use Ecto.Repo,
    otp_app: :auth_server,
    adapter: Ecto.Adapters.SQLite3

  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query


  @doc """
  Changeset for user registration
  """
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:tenant_id, :username, :email, :password_hash])
    |> validate_required([:tenant_id, :username, :email, :password_hash])
    |> validate_format(:email, ~r/@/, message: "must be a valid email")
    |> validate_length(:username, min: 3, max: 50)
    |> unique_constraint(:username, name: :users_username_tenant_id_index)
  end

  def create_user(user) do
    %__MODULE__{}
    |> changeset(user)
    |> insert()
  end

  def find_user_by_username(tenant_id, username) do
    query =
      from(u in __MODULE__,
        where: u.tenant_id == ^tenant_id and u.username == ^username
      )

    case one(query) do
      nil ->
        {:error, :not_found}

      user ->
        {:ok, user}
    end
  end

  def update_user(id, attrs) do
    case get(id) do
      nil ->
        {:error, :not_found}

      user ->
        user |> changeset(attrs) |> update()
    end
  end

  @doc """
  Delete a user by ID
  """
  def delete_user(id) do
    case get(id) do
      nil -> {:error, :not_found}
      user -> delete(user)
    end
  end

  @doc """
  Find a user by email
  """
  def find_user_by_email(email) do
    query = from(u in __MODULE__, where: u.email == ^email)

    case one(query) do
      nil -> {:error, :not_found}
      user -> {:ok, user}
    end
  end

  @doc """
  List users for a specific tenant
  """
  def list_users_for_tenant(tenant_id) do
    query =
      from(u in __MODULE__,
        where: u.tenant_id == ^tenant_id,
        select: u
      )

    all(query)
  end

  @doc """
  Check if a username exists in a tenant
  """
  def username_exists?(tenant_id, username) do
    query =
      from(u in __MODULE__,
        where: u.tenant_id == ^tenant_id and u.username == ^username,
        select: count(u.id)
      )

    one(query) > 0
  end
end
