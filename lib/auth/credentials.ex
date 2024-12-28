defmodule Auth.Credentials do
  @moduledoc """
  This is the core module for handling each tennants authentication storage.

  We will spin up a GenServer for each tennant, which we will assign to the 
  correct clients as they come in.
  """
  defstruct next_id: 1, entries: %{}

  @doc "Create a new authentication server."
  def new do
    %Auth.Credentials{}
  end

  def add_credentials(cred_list, username, password_hash) do
    entry = %{id: cred_list.next_id, username: username, password: password_hash}
    new_entries = Map.put(cred_list.entries, cred_list.next_id, entry)

    %Auth.Credentials{cred_list | entries: new_entries, next_id: cred_list.next_id + 1}
  end

  def entries(cred_list) do
    cred_list.entries
  end

  def update_entry(cred_list, id, updater_fn) do
    case Map.fetch(cred_list.entries, id) do
      :error ->
        cred_list

      {:ok, entry} ->
        new_entry = updater_fn.(entry)
        new_entries = Map.put(cred_list.entries, new_entry.id, new_entry)
        %Auth.Credentials{cred_list | entries: new_entries}
    end
  end

  def update_password(cred_list, id, password) do
    update_entry(cred_list, id, &Map.put(&1, :password, password))
  end

  def update_username(cred_list, id, username) do
    update_entry(cred_list, id, &Map.put(&1, :username, username))
  end

  def delete_entry(cred_list, id) do
    new_entries = Map.delete(cred_list.entries, id)
    %Auth.Credentials{cred_list | entries: new_entries}
  end
end
