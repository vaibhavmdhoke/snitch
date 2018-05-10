defmodule Snitch.OrderCase do
  import Snitch.Factory

  @line_item %{
    quantity: nil,
    unit_price: nil,
    total: nil,
    variant_id: nil,
    order_id: nil,
    inserted_at: Ecto.DateTime.utc(),
    updated_at: Ecto.DateTime.utc()
  }

  def line_items(variants, quantities, order_id \\ nil) do
    variants
    |> Stream.zip(quantities)
    |> Enum.map(fn
      {v, q} when is_map(v) ->
        %{@line_item | quantity: q, variant_id: v.id, order_id: order_id}

      {v, q} when is_integer(v) ->
        %{@line_item | quantity: q, variant_id: v, order_id: order_id}
    end)
  end

  def line_items_with_price(variants, quantities, order_id \\ nil) do
    variants
    |> line_items(quantities, order_id)
    |> Stream.zip(variants)
    |> Enum.map(fn {%{quantity: q} = li, v} when is_map(v) ->
      %{li | unit_price: v.selling_price, total: Money.mult!(v.selling_price, q)}
    end)
  end
end
