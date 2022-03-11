defmodule ExcmsCoreWeb.RouteAuthorizerBase do
  defmacro __using__(opts) do
    lazy_web_router =
      opts[:lazy_web_router] || &ExcmsCoreWeb.router/0

    authorizer =
      opts[:authorizer] || ExcmsCore.Authorizer

    authorization_extractor =
      opts[:authorization_extractor] || ExcmsCoreWeb.AuthorizationExtractor

    if Mix.env() != :test do
      opts[:lazy_web_router] &&
        raise ":lazy_web_router can be changed only in test env"

      opts[:authorizer] &&
        raise ":authorizer can be changed only in test env"

      opts[:authorization_extractor] &&
        raise ":authorization_extractor can be changed only in test env"
    end

    quote do
      def can_path?(conn, path, params \\ []) do
        method =
          Keyword.get(params, :method, :get)
          |> Plug.Router.Utils.normalize_method()

        authorization = extract_authorization(conn)
        router = get_router()

        reverse_controller(path, method, router)
        |> controller_can?(authorization, params)
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

      defp extract_authorization(conn) do
        unquote(authorization_extractor).extract(conn)
      end

      defp reverse_controller(path, method, router) do
        [path | _] = String.split(path, "?")

        Phoenix.Router.route_info(router, method, path, "")
      end

      defp get_router() do
        unquote(lazy_web_router).()
      end

      defp controller_can?(%{plug: controller, plug_opts: phoenix_action}, authorization, params) do
        params_map =
          Keyword.drop(params, [:method])
          |> Map.new()

        can =
          controller.required_permissions(phoenix_action, params_map)
          |> List.wrap()
          |> Enum.all?(fn {action, resource_or_module} ->
            unquote(authorizer).can?(authorization, action, resource_or_module)
          end)

        {:ok, can}
      end

      defp controller_can?(_error, _authorization, _params) do
        :error
      end
    end
  end
end
