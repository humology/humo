defmodule ExcmsCoreWeb.BrowserPlugs do
  @moduledoc false

  @plugs Application.compile_env!(:excms_core, __MODULE__)
  @server_app ExcmsCore.server_app()

  defmacro __using__(otp_app: @server_app) do
    @plugs
    |> Enum.flat_map(fn {_, data} -> data end)
    |> Enum.filter(fn {_, enabled} -> enabled end)
    |> Enum.map(fn {plug, _} ->
      quote do
        plug unquote(plug)
      end
    end)
  end

  defmacro __using__(_opts) do
    :ok
  end
end
