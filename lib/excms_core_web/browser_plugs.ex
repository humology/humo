defmodule ExcmsCoreWeb.BrowserPlugs do
  @moduledoc false

  @plugs Application.compile_env!(:excms_core, __MODULE__)

  defmacro __using__(_opts) do
    quote do
      if ExcmsCore.is_server_app_module(__MODULE__) do
        unquote do
          @plugs
          |> Enum.flat_map(fn {_, data} -> data end)
          |> Enum.filter(fn {_, enabled} -> enabled end)
          |> Enum.map(fn {plug, _} ->
            quote do
              plug unquote(plug)
            end
          end)
        end
      end
    end
  end
end
