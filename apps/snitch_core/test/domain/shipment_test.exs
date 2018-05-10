defmodule Snitch.Domain.ShipmentTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  import Snitch.{OrderCase, StockCase}
  import Snitch.Factory

  alias Snitch.Data.Schema.{StockItem, StockLocation, Order}
  alias Snitch.Domain.Shipment

  @sl_manifest %{
    "default" => %{
      default: true
    },
    "backup" => %{},
    "origin" => %{}
  }

  @si_manifest %{
    "default" => [
      %{count_on_hand: 3, backorderable: true},
      %{count_on_hand: 3, backorderable: true},
      %{count_on_hand: 3, backorderable: true}
    ],
    "backup" => [
      %{count_on_hand: 0},
      %{count_on_hand: 0},
      %{count_on_hand: 6}
    ],
    "origin" => [
      %{count_on_hand: 3},
      %{count_on_hand: 3},
      %{count_on_hand: 3}
    ]
  }

  setup :variants
  setup :stock_locations
  setup :stock_items

  @tag variant_count: 3
  test "lol", %{variants: vs} = context do
    line_items = line_items_with_price(vs, [1, 1, 1])
    order = %Order{id: 42, line_items: line_items}

    Shipment.default_packages(order)
    |> IO.inspect()
  end

  defp stock_locations(context) do
    locations =
      context
      |> Map.get(:stock_location_manifest, @sl_manifest)
      |> stock_locations_with_manifest()

    {_, stock_locations} = Repo.insert_all(StockLocation, locations, returning: true)

    [stock_locations: stock_locations]
  end

  defp stock_items(%{variants: vs, stock_locations: locations} = context) do
    stock_items =
      context
      |> Map.get(:stock_item_manifest, @si_manifest)
      |> stock_items_with_manifest(vs, locations)

    {9, stock_items} = Repo.insert_all(StockItem, stock_items, returning: true)

    [stock_items: stock_items]
  end
end