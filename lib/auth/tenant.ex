defmodule Auth.Tenant do
  use Ecto.Schema
  import Ecto.Changeset

  @tenant_statuses [:pending, :active, :suspended, :deleted]

  schema "tenants" do
    field(:name, :string)
    field(:status, Ecto.Enum, values: @tenant_statuses, default: :pending)
    field(:created_at, :naive_datetime)
    field(:last_active_at, :naive_datetime)
    field(:suspended_at, :naive_datetime)
    field(:deleted_at, :naive_datetime)
    field(:metadata, :map, default: %{})

    timestamps()
  end

  def changeset(tenant, attrs) do
    tenant
    |> cast(attrs, [
      :name,
      :status,
      :created_at,
      :last_active_at,
      :suspended_at,
      :deleted_at,
      :metadata
    ])
    |> validate_required([:name])
    |> validate_inclusion(:status, @tenant_statuses)
  end
end
