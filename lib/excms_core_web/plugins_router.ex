defmodule ExcmsCoreWeb.PluginsRouter do
  @moduledoc false

  @routers Application.compile_env!(:excms_core, __MODULE__)
  @server_app ExcmsCore.server_app()

  defmacro __using__(otp_app: @server_app) do
    quote do
      if __MODULE__ != ExcmsCoreWeb.router(), do:
        raise """
        Please set router name to #{ExcmsCoreWeb.router()}

        defmodule #{ExcmsCoreWeb.router()} do
        ...
        """

      pipeline :excms_core_dashboard do
        plug :put_layout, {ExcmsCoreWeb.LayoutView, "dashboard.html"}
      end

      scope "/" do
        pipe_through :browser

        unquote do
          quote_routers(:routers)
        end

        scope "/humo", as: :dashboard do
          pipe_through :excms_core_dashboard

          unquote do
            quote_routers(:dashboard_routers)
          end
        end
      end
    end
  end

  defmacro __using__(_opts) do
    quote do
      if ExcmsCoreWeb.is_server_app_web_module(__MODULE__), do:
        raise """
        Please set correct otp_app
        use ExcmsCoreWeb.PluginsRouter, otp_app: :#{ExcmsCore.server_app()}
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
