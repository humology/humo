defmodule HumoWeb.BrowserPlugs do
  @moduledoc false

  @plugs Application.compile_env!(:humo, __MODULE__)
  @server_app Humo.server_app()

  defmacro __using__(otp_app: @server_app) do
    quote do
      if __MODULE__ != HumoWeb.router(),
        do:
          raise("""
          Please set router name to #{HumoWeb.router()}

          defmodule #{HumoWeb.router()} do
          ...
          """)
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
      if HumoWeb.is_server_app_web_module(__MODULE__),
        do:
          raise("""
          Please set correct otp_app
          use HumoWeb.BrowserPlugs, otp_app: :#{Humo.server_app()}
          """)
    end
  end
end
