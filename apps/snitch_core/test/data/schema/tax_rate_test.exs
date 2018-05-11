defmodule Snitch.Data.Schema.TaxRateTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase
  import Snitch.Factory
  alias Snitch.Repo
  alias Snitch.Data.Schema.TaxRate

  @valid_params %{
    name: "North America",
    value: 0.5,
    included_in_price: false,
    calculator: :DefaultCalculator
  }

  setup :tax_rate_params

  describe "creation" do
    test "with valid params", context do
      %{tax_rate_params: params} = context
      changeset = %{valid?: validity} = TaxRate.create_changeset(%TaxRate{}, params)
      assert validity
      assert {:ok, _} = Repo.insert(changeset)
    end

    test "unsuccessful, missing required params", context do
      %{tax_rate_params: params} = context
      params = Map.drop(params, [:tax_category_id])
      %{valid?: validity} = TaxRate.create_changeset(%TaxRate{}, params)
      refute validity
    end
  end

  describe "updation" do
    test "update tax rate name", context do
      %{tax_rate_params: params} = context
      changeset = TaxRate.create_changeset(%TaxRate{}, params)
      assert {:ok, tax_rate} = Repo.insert(changeset)

      params = %{name: "Europe"}
      %{valid?: validity} = TaxRate.update_changeset(tax_rate, params)
      assert validity
    end
  end

  defp tax_rate_params(_context) do
    zone = insert(:zone, %{zone_type: "S"})
    tax_category = insert(:tax_category)

    params =
      @valid_params
      |> Map.put(:tax_category_id, tax_category.id)
      |> Map.put(:zone_id, zone.id)

    [tax_rate_params: params]
  end
end
