defmodule ExcmsCoreWeb.PluginsRouter do
  @moduledoc false

  @routers Application.compile_env!(:excms_core, __MODULE__)

  defmacro __using__(_opts) do
    quote do
      if ExcmsCore.is_server_app_module(__MODULE__) do
        pipeline :excms_core_dashboard do
          plug ExcmsCoreWeb.DashboardAccessPlug
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
