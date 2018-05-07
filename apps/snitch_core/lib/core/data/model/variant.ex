defmodule Snitch.Data.Model.Variant do
  @moduledoc """
  Variant API
  """
  use Snitch.Data.Model
  alias Snitch.Data.Schema.Variant

  def get_category(%Variant{} = v) do
    0
  end
end
