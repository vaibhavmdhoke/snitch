defmodule Snitch.Domain.Shipment do
  @moduledoc """
  The coordinator, packer, estimator and prioritizer -- all in one.

  The package struct:
  ```
  %{
    items: %{
      variant_id: %{
        state: :fulfilled | :backorder,
        quantity: 0,
        price: Money.zero(:USD),
        height: 0,
        width: 0,
        breadth: 0,
        weight: 0
      },
      shipping_methods: [],
      origin: 0,
      category_id: 0
      backorders?: false
    }
  }
  ```
  """

  use Snitch.Domain

  alias Snitch.Data.Schema.{Order}
  alias Snitch.Data.Model.{StockLocation, Variant}

  def default_packages(%Order{} = order) do
    order = Repo.preload(order, line_items: [])
    variant_ids = Enum.map(order.line_items, fn %{variant_id: id} -> id end)
    stocks = StockLocation.get_all_with_items_for_variants(variant_ids)

    line_items =
      Enum.reduce(order.line_items, %{}, fn %{variant_id: v_id} = li, acc ->
        Map.put(acc, v_id, li)
      end)

    Enum.map(stocks, &package(&1, line_items))
  end

  defp package(stock_location, line_items) do
    # TODO: Bad quantity!
    #
    # It is always set to the quantity required in the order. Shouldn't it be
    # the quantity that is right now on_hand (even in the case of a backorder?)

    # TODO: Bad price!
    #
    # Should it be (on_hand * selling_price) or (quantity * selling_price)?

    items =
      stock_location.stock_items
      |> Stream.map(&make_item(&1, line_items))
      |> Stream.reject(fn x -> is_nil(x) end)

    %{
      items: items,
      shipping_methods: [],
      origin: struct(stock_location, stock_items: nil),
      category_id: nil,
      backorders?: Enum.any?(items, fn %{state: state} -> state == :backordered end)
    }
  end

  defp make_item(%{variant_id: v_id} = stock_item, line_items) do
    li = line_items[v_id]
    state = item_state(stock_item, li)

    if is_nil(state),
      do: nil,
      else: %{
        state: state,
        quantity: li.quantity,
        price: li.total,
        height: stock_item.variant.height,
        width: stock_item.variant.width,
        depth: stock_item.variant.depth,
        weight: stock_item.variant.weight,
        category: Variant.get_category(stock_item.variant)
      }
  end

  defp item_state(stock_item, line_item) do
    if line_item.quantity < stock_item.count_on_hand do
      if stock_item.backorderable, do: :backordered, else: nil
    else
      :fulfilled
    end
  end
end
