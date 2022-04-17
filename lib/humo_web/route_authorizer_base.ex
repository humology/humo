defmodule HumoWeb.RouteAuthorizerBase do
  defmacro __using__(opts) do
    lazy_web_router =
      opts[:lazy_web_router] || &HumoWeb.router/0

    if Mix.env() != :test do
      opts[:lazy_web_router] &&
        raise ":lazy_web_router can be changed only in test env"
    end

    quote do
      def can_path?(conn, path, method \\ :get) do
        method = Plug.Router.Utils.normalize_method(method)
        router = get_router()

        reverse_controller(path, method, router)
        |> controller_can?(conn)
        |> case do
          {:ok, can?} -> can?
          :error -> raise no_route_error(conn, path, method, router)
        end
      end

      defp no_route_error(conn, path, method, router) do
        [
          conn: %{conn | path_info: split_path(path), method: method},
          router: router
        ] |> Phoenix.Router.NoRouteError.exception()
      end

      defp split_path(path) do
        for x <- String.split(path, "/"), x != "", do: x
      end

      defp reverse_controller(path, method, router) do
        [path | _] = String.split(path, "?")

        Phoenix.Router.route_info(router, method, path, "")
      end

      defp get_router() do
        unquote(lazy_web_router).()
      end

      defp controller_can?(%{plug: controller, plug_opts: phoenix_action}, conn) do
        {:ok, controller.can?(conn, phoenix_action)}
      end

      defp controller_can?(_error, _conn) do
        :error
      end
    end
  end
end
