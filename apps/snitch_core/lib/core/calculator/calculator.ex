defmodule Calculator do
  @moduledoc """
  Base Calculator module.
  """

  @callback compute(term, TaxRate.t()) :: Money.t()

  def calculator_types() do
  end
end
