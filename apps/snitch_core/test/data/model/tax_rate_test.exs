defmodule Snitch.Data.Model.TaxRateTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  import Snitch.Factory

  alias Snitch.Data.Model.TaxRate, as: TaxRateModel
  alias Snitch.Data.Schema.TaxRate

  @valid_params %{
    name: "Europe",
    value: 0.5,
    included_in_price: false,
    calculator: "DefaultCalculator"
  }

  describe "create/1" do
    test "tax rate successfully" do
      params = create_tax_params()
      assert {:ok, _} = TaxRateModel.create(params)
    end

    test "fails, name missing" do
      params = create_tax_params()
      params = Map.drop(params, [:name])
      assert {:error, cs} = TaxRateModel.create(params)
      assert %{name: ["can't be blank"]} = errors_on(cs)
    end

    test "fails, calculator missing" do
      params = create_tax_params()
      params = Map.drop(params, [:calculator])
      assert {:error, cs} = TaxRateModel.create(params)
      assert %{calculator: ["can't be blank"]} = errors_on(cs)
    end
  end

  describe "update/2" do
    setup :tax_rate

    test "successfuly calculator field", context do
      params = %{calculator: "FlatRateCalculator"}
      %{tax_rate: tr} = context
      assert {:ok, tr_new} = TaxRateModel.update(params, tr)
      assert tr_new.id == tr.id
      refute tr_new.calculator == tr.calculator
    end

    test "successful without instance", context do
      %{tax_rate: tr} = context
      params = %{name: "Germany", id: tr.id}
      assert {:ok, tr_new} = TaxRateModel.update(params)
      assert tr_new.id == tr.id
      refute tr_new.name == tr.name
    end

    test "failed, name missing", context do
      %{tax_rate: tr} = context
      params = %{name: "", id: tr.id}
      assert {:error, cs} = TaxRateModel.update(params)
      assert %{name: ["can't be blank"]} = errors_on(cs)
    end
  end

  describe "delete/1" do
    setup :tax_rate

    test "tax category successfully, with instance", context do
      %{tax_rate: tr} = context
      assert {:ok, tr_deleted} = TaxRateModel.delete(tr)
      refute is_nil(tr_deleted.deleted_at)
      tr_received = Repo.get(TaxRate, tr_deleted.id)
      refute is_nil(tr_received)
    end

    test "tax category successfully, with id", context do
      %{tax_rate: tr} = context
      assert {:ok, tr_deleted} = TaxRateModel.delete(tr.id)
      refute is_nil(tr_deleted.deleted_at)
      tr_received = Repo.get(TaxRate, tr_deleted.id)
      refute is_nil(tr_received)
    end
  end

  describe "get/2" do
    setup :tax_rate

    test "tax rate", context do
      %{tax_rate: tr} = context
      tr_ret = TaxRateModel.get(tr.id)
      assert tr.id == tr_ret.id
    end

    test "no tax rate, is deleted", context do
      %{tax_rate: tr} = context
      assert {:ok, tr} = TaxRateModel.delete(tr)
      refute is_nil(tr.deleted_at)
      tr_ret = TaxRateModel.get(tr.id)
      assert is_nil(tr_ret)
    end

    test "tax category, is deleted", context do
      %{tax_rate: tr} = context
      {:ok, tr} = TaxRateModel.delete(tr)
      refute is_nil(tr.deleted_at)
      tr_ret = TaxRateModel.get(tr.id, false)
      refute is_nil(tr_ret)
    end
  end

  describe "get_all/1" do
    setup :tax_rates

    @tag tax_rate_count: 2
    test "tax categories" do
      tax_rates = TaxRateModel.get_all()
      assert length(tax_rates) == 2
      assert {:ok, _} = TaxRateModel.delete(List.first(tax_rates))
      tax_rates = TaxRateModel.get_all()
      assert length(tax_rates) == 1
    end

    @tag tax_rate_count: 2
    test "tax categories including, soft deleted" do
      tax_rates = TaxRateModel.get_all()
      assert length(tax_rates) == 2
      assert {:ok, _} = TaxRateModel.delete(List.first(tax_rates))
      tax_rates = TaxRateModel.get_all(false)
      assert length(tax_rates) == 2
    end

    test "tax categories for no record" do
      Repo.delete_all(TaxRate)
      tax_rates = TaxRateModel.get_all()
      assert tax_rates == []
    end
  end

  defp create_tax_params do
    tc = insert(:tax_category)
    zone = insert(:zone, %{zone_type: "S"})

    @valid_params
    |> Map.put(:tax_category_id, tc.id)
    |> Map.put(:zone_id, zone.id)
  end
end
