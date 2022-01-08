defmodule ExcmsCoreWeb.BrowserPlugs do
  @moduledoc false

  @plugs Application.compile_env!(:excms_core, __MODULE__)
  @server_app ExcmsCore.server_app()

  defmacro __using__(otp_app: @server_app) do
    quote do
      if __MODULE__ != ExcmsCoreWeb.router(), do:
        raise """
        Please set router name to #{ExcmsCoreWeb.router()}

        defmodule #{ExcmsCoreWeb.router()} do
        ...
        """
    end

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
    quote do
      if ExcmsCoreWeb.is_server_app_web_module(__MODULE__), do:
        raise """
        Please set correct otp_app
        use ExcmsCoreWeb.BrowserPlugs, otp_app: :#{ExcmsCore.server_app()}
        """
    end
  end
end
