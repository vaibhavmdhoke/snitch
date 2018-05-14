defmodule Snitch.Core.Domain.Splitters.Weight do
  @default_threshold Decimal.new(150)

  def split(packages) do
    packages
    |> Enum.map(&sort_line_items_by_weight/1)
  end

  def sort_line_items_by_weight(package) do
    sorted_line_items =
      package.items
      |> Enum.sort(&compare_weight/2)

    %{package | items: sorted_line_items}
  end

  def compare_weight(item1, item2) do
    weight1 = item1.variant.weight
    weight2 = item2.variant.weight

    case Decimal.cmp(weight1, weight2) do
      :gt -> true
      _ -> false
    end
  end
end
