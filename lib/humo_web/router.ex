defmodule HumoWeb.Router do
  use HumoWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {HumoWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers

    use HumoWeb.BrowserPlugs, otp_app: :humo
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :humo_dashboard do
    plug :put_root_layout, {HumoWeb.LayoutView, "dashboard.html"}
  end

  scope "/", HumoWeb do
    pipe_through :browser

    get "/", PageController, :index

    scope "/humo", Dashboard, as: :dashboard do
      pipe_through :humo_dashboard

      get "/", PageController, :index
    end
  end

  use HumoWeb.PluginsRouter, otp_app: :humo

  # Other scopes may use custom stacks.
  # scope "/api", HumoWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: HumoWeb.Telemetry
    end
  end
end
