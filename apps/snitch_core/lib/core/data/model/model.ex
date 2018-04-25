defmodule Snitch.Data.Model do
  @moduledoc """
  Interface for handling DB related changes
  """

  defmacro __using__(_) do
    quote do
      import Ecto.Query
      alias Snitch.Repo
      alias Snitch.Tools
      alias Snitch.Data.Model
      alias Tools.QueryHelper, as: QH
    end
  end
end
