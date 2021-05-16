defmodule ExcmsCoreWeb.BrowserPlugs do
  @moduledoc false

  @plugs Application.compile_env!(:excms_core, __MODULE__)

  defmacro __using__(_opts) do
    @plugs
    |> Enum.flat_map(fn {_, data} -> data end)
    |> Enum.map(fn plug ->
      quote do
        plug unquote(plug)
      end
    end)
  end
end
