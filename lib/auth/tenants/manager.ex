defmodule Auth.Tenants.Manager do
  use GenServer

  # By providing a name, we are making this process unique
  def start_link(opts \\ []) do
    IO.puts("Tenants.Manager start_link is running")
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_opts) do
    IO.puts("Tenants.Manager init is running")
    # Start mnesia for multi-tenant storage
    :mnesia.create_schema([node()])
    :mnesia.start()

    :mnesia.create_table(:tenants,
      attributes: [:id, :name, :config],
      disc_copies: [node()],
      type: :set
    )

    :mnesia.create_table(:users,
      attributes: [:id, :tenant_id, :username, :email, :password_hash],
      disc_copies: [node()],
      type: :set,
      index: [:email, :tenant_id]
    )

    {:ok, %{}}
  end

  def create_tenant(name, config \\ %{}) do
    tenant_id = :crypto.strong_rand_bytes(16) |> Base.url_encode64()

    :mnesia.transaction(fn -> :mnesia.write({:tenants, tenant_id, name, config}) end)

    {:ok, tenant_id}
  end

  def get_tenant(tenant_id) do
    :mnesia.transaction(fn ->
      case :mnesia.read({:tenants, tenant_id}) do
        [{:tenants, ^tenant_id, name, config}] ->
          {:ok, %{id: tenant_id, name: name, config: config}}

        [] ->
          {:error, :tenant_not_found}
      end
    end)
  end
end
