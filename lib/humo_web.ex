defmodule HumoWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.

  This can be used in your application as:

      use HumoWeb, :controller
      use HumoWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

  def router(), do: Module.concat([server_app_web_namespace(), "Router"])

  def routes(), do: Module.concat([server_app_web_namespace(), "Router", "Helpers"])

  def endpoint(), do: Module.concat([server_app_web_namespace(), "Endpoint"])

  def layout_view(), do: Module.concat([server_app_web_namespace(), "LayoutView"])

  def is_server_app_web_module(module) when is_atom(module) do
    hd(Module.split(module)) == server_app_web_namespace()
  end

  defp server_app_web_namespace() do
    Humo.server_app()
    |> to_string()
    |> Macro.camelize()
    |> then(&"#{&1}Web")
  end

  def controller_macro do
    quote do
      use Phoenix.Controller, namespace: HumoWeb

      import Plug.Conn
      import HumoWeb.Gettext
    end
  end

  def view_macro do
    quote do
      use Phoenix.View,
        root: "lib/humo_web/templates",
        namespace: HumoWeb

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_flash: 1, get_flash: 2, view_module: 1, view_template: 1]

      # Include shared imports and aliases for views
      unquote(view_helpers_macro())
    end
  end

  def router_macro do
    quote do
      use Phoenix.Router

      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
    end
  end

  def channel_macro do
    quote do
      use Phoenix.Channel
      import HumoWeb.Gettext
    end
  end

  defp view_helpers_macro do
    quote do
      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      # Import LiveView and .heex helpers (live_render, live_patch, <.form>, etc)
      import Phoenix.LiveView.Helpers

      # Import basic rendering functionality (render, render_layout, etc)
      import Phoenix.View

      import HumoWeb.ErrorHelpers
      import HumoWeb.Gettext
      import HumoWeb, only: [routes: 0]
      import HumoWeb.RouteAuthorizer
      import HumoWeb.AuthorizeViewHelpers
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, :"#{which}_macro", [])
  end
end
