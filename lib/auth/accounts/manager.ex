defmodule Auth.Accounts.Manager do
  alias Auth.Repo
  alias Auth.Accounts.User

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
end
