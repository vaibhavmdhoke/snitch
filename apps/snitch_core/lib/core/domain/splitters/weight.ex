defmodule Snitch.Core.Domain.Splitters.Weight do
  @bin_threshold 7

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

  def add_item_to_bin(item, []) do
    [[item]]
  end

  def add_item_to_bin(item, acc) do
    put_in_bin(item, acc, acc)
  end

  def put_in_bin(item, [], acc) do
    [[item] | acc]
  end

  def put_in_bin(item, [first_bin | rest_bins], acc) do
    total = first_bin |> Enum.reduce(0, fn item, acc -> item + acc end)

    next_total = total + item

    case next_total <= @bin_threshold do
      true ->
        update_bin = [item | first_bin]
        temp = List.delete(acc, first_bin)
        [update_bin | temp]

      false ->
        put_in_bin(item, rest_bins, acc)
    end
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
