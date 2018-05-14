defmodule Snitch.Calculator.DefaultCalculator do
  @moduledoc """
  This module provides `compute` function for DefaultCalculator.
  """
  @behaviour Snitch.Calculator

  alias Snitch.Data.Schema.LineItem

  def compute(tax_rate, %LineItem{} = lineitem) do
    {:ok, value} =
      if tax_rate.included_in_price do
        {:ok, offset} = Money.div(lineitem.total, 1 + tax_rate.value)
        Money.sub(lineitem.total, offset)
      else
        Money.mult(lineitem.total, tax_rate.value)
      end

    Money.round(value)
  end
end
