defmodule ExcmsCoreWeb.PluginsRouter do
  @moduledoc false

  @routers Application.compile_env!(:excms_core, __MODULE__)

  defmacro __using__(_opts) do
    quote do
      pipeline :excms_core_layout do
        plug :put_layout, {ExcmsCoreWeb.LayoutView, "cms.html"}
      end

      scope "/" do
        pipe_through :browser

        unquote do
          quote_routers(:routers)
        end

        scope "/cms", as: :cms do
          pipe_through :excms_cms

          unquote do
            quote_routers(:cms_routers)
          end
        end
      end
    end
  end

  defp quote_routers(key) do
    @routers
    |> Enum.flat_map(fn {_, data} -> data[key] || [] end)
    |> Enum.map(fn routers ->
      quote do
        use unquote(routers)
      end
    end)
  end
end
