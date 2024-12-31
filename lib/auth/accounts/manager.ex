defmodule Auth.Accounts.Manager do
  alias Auth.Repo
  alias Auth.Accounts.User

  def create_user(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def get_user!(id), do: Repo.get!(User, id)
end
