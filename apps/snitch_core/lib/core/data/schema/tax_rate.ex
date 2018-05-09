defmodule Snitch.Data.Schema.TaxRate do
  @moduledoc """
  Models a TaxRate
  """

  use Snitch.Data.Schema
  alias Snitch.Data.Schema.TaxCategory
  alias Snitch.Data.Schema.Zone

  @type t :: %__MODULE__{}

  schema "snitch_tax_rates" do
    # associations
    belongs_to(:tax_category, TaxCategory)
    belongs_to(:zone, Zone)

    field(:name, :string)
    field(:value, :decimal)
    field(:calculator, Ecto.Atom)
    field(:deleted_at, :utc_datetime)
    field(:included_in_price, :boolean, default: false)

    timestamps()
  end

  @required_params ~w(name value tax_category_id calculator)a
  @optional_params ~w(zone_id deleted_at)a
  @create_params @required_params + @optional_params
  @update_params @required_params + @optional_params

  @doc """
  Returns a changeset to create a new TaxRate
  """
  @spec create_changeset(t, map) :: Ecto.Changeset.t()
  def create_changeset(%__MODULE__{} = tax_rate, params) do
    tax_rate
    |> cast(params, @create_params)
    |> common_changeset()
  end

  @doc """
  Returns a changeset to update a TaxRate.
  """
  @spec update_changeset(t, map) :: Ecto.Changeset.t()
  def update_changeset(%__MODULE__{} = tax_rate, params) do
    tax_rate
    |> cast(params, @update_params)
    |> common_changeset()
  end

  defp common_changeset(changeset) do
    changeset
    |> validate_required(@required_params)
    |> validate_number(:value, greater_than: 0)
  end
end
