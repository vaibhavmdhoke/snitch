defmodule AdminAppWeb.StockLocationController do
  use AdminAppWeb, :controller
  alias Snitch.Domain, as: SD

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def list(conn, _params) do
    data = %{stock_locations: SD.StockLocation.search()}
    render(conn, "list.json", data)
  end
end
