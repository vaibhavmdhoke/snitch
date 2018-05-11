defmodule Snitch.Tools.UserConfigTest do
  use ExUnit.Case, async: false
  alias Snitch.Tools.UserConfig

  describe "configured properly" do
    setup do
      Application.put_env(:snitch_core, :calculators, [TaxCalculator, FlatRateCalculator])

      on_exit(fn ->
        Application.delete_env(:snitch_core, :calculators)
      end)
    end

    test "fetch all calculators" do
      assert {:ok, list} = UserConfig.fetch(:calculators)
      assert length(list) == 2
    end

    test "get all calculators" do
      list = UserConfig.get(:calculators)
      assert length(list) == 2
    end
  end

  describe "not configured properly," do
    test "fetch none return error" do
      assert :error = UserConfig.fetch(:calculators)
    end

    test "get none" do
      list = UserConfig.get(:calculators)
      assert is_nil(list)
    end
  end
end
