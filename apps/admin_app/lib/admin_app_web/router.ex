defmodule AdminAppWeb.Router do
  use AdminAppWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", AdminAppWeb do
    # Use the default browser stack
    pipe_through(:browser)

    get("/", PageController, :index)

    resources("/orders", OrderController, only: ~w[index show]a, param: "slug") do
      get("/cart", OrderController, :edit, as: :cart)
      post("/cart", OrderController, :update, as: :cart)
    end
    get("/stock_locations", StockLocationController, :index)
    get("/stock_locations/list", StockLocationController, :list)
  end

  # Other scopes may use custom stacks.
  # scope "/api", AdminAppWeb do
  #   pipe_through :api
  # end
end
