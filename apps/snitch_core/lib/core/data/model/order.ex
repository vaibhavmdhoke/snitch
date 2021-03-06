defmodule Snitch.Data.Model.Order do
  @moduledoc """
  Order API
  """
  use Snitch.Data.Model
  alias Snitch.Data.Schema.Order
  alias Snitch.Data.Model.LineItem, as: LineItemModel

  @doc """
  Creates an order with supplied `params` and `line_items`.

  Since line-items are "owned" by an order it does not make sense to persist
  `LineItem`s first and then `create/2` an `Order`.

  `params` is a map that is passed to the
  `Snitch.Data.Schema.Order.changeset/3`.

  > * `line_items` is not a list of `LineItem` schema structs, but just a list
  >   of maps with the keys `:variant_id` and `:quantity`.
  > * These `LineItem`s will be created (casted, to be precise) along with the
  >   `Order` in a DB transaction.

  ## Example
  ```
  line_items = [%{variant_id: 1, quantity: 42}, %{variant_id: 2, quantity: 42}]
  params = %{user_id: 1}
  {:ok, order} = Snitch.Data.Model.Order.create(params, line_items)
  ```

  ## See also
  `Ecto.Changeset.cast_assoc/3`
  """
  @spec create(map, [line_items]) :: {:ok, Order.t()} | {:error, Ecto.Changeset.t()}
        when line_items: %{variant_id: non_neg_integer, quantity: non_neg_integer}
  def create(params, line_items) do
    priced_items = update_line_item_costs(line_items)

    QH.create(Order, Map.put(params, :line_items, priced_items), Repo)
  end

  @doc """
  Updates the order with supplied `params`. `params` can include "new"
  `line_items`.

  ## Caution!

  The `line_items` are "casted" with the order and if `params` does not include
  a `line_items`, then **all previous line-items will be deleted!**

  ### Retain previous `LineItem`s

  If you wish to retain the line-items, you must pass a list of maps with the
  line-item `:id`s, like so:

  ```
  order # this is the order you wish to update, and `:line_items` are preloaded
  line_items = Enum.reduce(order.line_items, [], fn x, acc -> 
    [%{id: x.id} | acc]
  end)
  params = %{} # All changes except line-items
  all_params = Map.put(params, :line_items, line_items)

  Snitch.Data.Model.Order.update(all_params, order)
  ```

  ### Updating some of the `LineItem`s

  Just like `create/2`, `line_items` is a list of maps, passing `LineItem`
  schema structs instead would fail. Along with the line-item params
  (`:variant_id` and `:quantity`) just pass the line-item `:id`.

  Let's say we have an `order` with the following `LineItem`s:
  ```
  order.line_items
  #=> [
  ..>   %LineItem{id: 1, quantity: 1, variant_id: 1, ...},
  ..>   %LineItem{id: 2, quantity: 1, variant_id: 3, ...},
  ..>   %LineItem{id: 3, quantity: 1, variant_id: 2, ...}
  ..> ]
  ```

  And we wish to:
  1. update the first,
  2. retain the second,
  3. remove the third and,
  4. add a "new" LineItem

  ```
  line_items = [
    %{id: 1, quantity: 42},        # updates quantity of first
    %{id: 2}                       # retains second
    %{variant_id: 4, quantity: 42} # adds a new line-item (no `:id`)
  ]                                # since there is no mention of `id: 3`,
                                   # it gets removed!

  params = %{line_items: line_items}
  {:ok, updated_order} = Snitch.Data.Model.Order.update(params, order)
  ```

  Let's see what we got,
  ```
  updated_order.line_items
  #=> [
  ..>   %LineItem{id: 1, quantity: 42, variant_id: 1, ...},
  ..>   %LineItem{id: 2, quantity: 42, variant_id: 2, ...},
  ..>   %LineItem{id: 4, quantity: 42, variant_id: 4, ...}
  ..> ]
  ```

  ## See also
  `Ecto.Changeset.cast_assoc/3`
  """
  @spec update(map, Order.t()) :: {:ok, Order.t()} | {:error, Ecto.Changeset.t()}
  def update(params, order \\ nil) do
    priced_items =
      params
      |> Map.get(:line_items, [])
      |> update_line_item_costs()

    QH.update(Order, Map.put(params, :line_items, priced_items), order, Repo)
  end

  @spec delete(non_neg_integer | Order.t()) ::
          {:ok, Order.t()} | {:error, Ecto.Changeset.t()} | {:error, :not_found}
  def delete(id_or_instance) do
    QH.delete(Order, id_or_instance, Repo)
  end

  @spec get(map | non_neg_integer) :: Order.t() | nil
  def get(query_fields_or_primary_key) do
    QH.get(Order, query_fields_or_primary_key, Repo)
  end

  @spec get_all() :: [Order.t()]
  def get_all, do: Repo.all(Order)

  # Compute price totals only if line_items are going to be changed
  defp update_line_item_costs(line_items) when is_list(line_items) do
    if Enum.empty?(line_items) do
      line_items
    else
      LineItemModel.update_price_and_totals(line_items)
    end
  end
end
