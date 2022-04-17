defmodule HumoWeb.PluginsRouter do
  @moduledoc false

  @routers Application.compile_env!(:humo, __MODULE__)
  @server_app Humo.server_app()

  defmacro __using__(otp_app: @server_app) do
    quote do
      if __MODULE__ != HumoWeb.router(), do:
        raise """
        Please set router name to #{HumoWeb.router()}

        defmodule #{HumoWeb.router()} do
        ...
        """

      pipeline :humo_dashboard do
        plug :put_layout, {HumoWeb.LayoutView, "dashboard.html"}
      end

      scope "/" do
        pipe_through :browser

        unquote do
          quote_routers(:routers)
        end

        scope "/humo", as: :dashboard do
          pipe_through :humo_dashboard

          unquote do
            quote_routers(:dashboard_routers)
          end
        end
      end
    end
  end

  defmacro __using__(_opts) do
    quote do
      if HumoWeb.is_server_app_web_module(__MODULE__), do:
        raise """
        Please set correct otp_app
        use HumoWeb.PluginsRouter, otp_app: :#{Humo.server_app()}
        """
    end
  end

  defp quote_routers(key) do
    @routers
    |> Enum.flat_map(fn {_, data} -> data[key] || [] end)
    |> Enum.map(fn router ->
      quote do
        use unquote(router)
      end
    end)
  end
end
