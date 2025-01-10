defmodule Auth.Tenants.Manager do
  alias Auth.Repo
  alias Auth.Tenants.{Tenant, Supervisor}

  require Ecto.Query

  def start_tenants do
    Repo.all(Tenant)
    |> Enum.each(fn tenant -> Supervisor.start_tenant(tenant.id) end)
  end

  @doc """
  Creates a new entry in the database and requests a new tenant 
  server which will be used to handle tenant requests
  """
  def start_new_tenant(attrs) do
    case process_tenant_attrs(attrs) do
      {:error, msg} ->
        {:error, msg}

      valid_attrs ->
        case create_tenant(valid_attrs) do
          {:ok, tenant} ->
            Supervisor.start_tenant(tenant.id)

          {:error, _changeset} ->
            {:error, :database_error}
        end
    end
  end

  @doc """
  Creates a tenant entry in the database.
  """
  def create_tenant(attrs) do
    %Tenant{}
    |> Tenant.changeset(attrs)
    |> Tenant.put_api_key()
    |> Tenant.put_secret_key()
    |> Repo.insert()
  end

  def get_tenant_with_users(tenant_id) do
    case Auth.Repo.get(Tenant, tenant_id) |> Repo.preload(:users) do
      nil -> {:error, :tenant_not_found}
      tenant -> tenant
    end
  end

  # TODO: This should be a get_by with proper error handling, there is no need to crash here
  def get_tenant!(id), do: Repo.get!(Tenant, id)
  def get_tenant_by_slug(slug), do: Repo.get_by(Tenant, slug: slug)

  defp process_tenant_attrs(%{name: name, settings: settings}) do
    %{
      name: name,
      slug: Utils.slugify(name),
      settings: settings
    }
  end

  defp process_tenant_attrs(%{name: name}) do
    %{
      name: name,
      slug: Utils.slugify(name)
    }
  end

  defp process_tenant_attrs(_) do
    {:error, "name is required"}
  end
end
