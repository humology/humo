defmodule HumoWeb.PluginsRouter do
  @moduledoc false

  @routers Application.compile_env(:humo, __MODULE__, [])
  @otp_app Humo.otp_app()

  defmacro __using__(otp_app: @otp_app) do
    quote do
      if __MODULE__ != HumoWeb.router(),
        do:
          raise("""
          Please set router name to #{HumoWeb.router()}

          defmodule #{HumoWeb.router()} do
          ...
          """)

      scope "/" do
        pipe_through :browser

        unquote do
          quote_routers(:root)
        end

        scope "/humo", as: :dashboard do
          pipe_through :humo_dashboard

          unquote do
            quote_routers(:dashboard)
          end
        end
      end
    end
  end

  defmacro __using__(_opts) do
    quote do
      if HumoWeb.is_otp_app_web_module(__MODULE__),
        do:
          raise("""
          Please set correct otp_app
          use HumoWeb.PluginsRouter, otp_app: :#{Humo.otp_app()}
          """)
    end
  end

  defp quote_routers(key) do
    @routers
    |> Enum.reject(fn {_, plugin_router} -> is_nil(plugin_router) end)
    |> Enum.map(fn {plugin_app, plugin_router} ->
      quote location: :keep do
        scope "/", as: unquote(plugin_app) do
          use unquote(plugin_router), unquote(key)
        end
      end
    end)
  end
end
