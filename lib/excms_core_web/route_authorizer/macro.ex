defmodule ExcmsCoreWeb.RouteAuthorizer.Macro do
  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(opts) do
    lazy_router = opts[:lazy_router] || raise ":lazy_router is expected to be given"
    user_extractor = opts[:user_extractor] || raise ":user_extractor is expected to be given"

    quote do
      def can_conn?(conn, params \\ []) do
        can_path?(conn, conn.request_path, params)
      end

      def can_path?(conn, path, params \\ []) do
        method =
          Keyword.get(params, :method, :get)
          |> Plug.Router.Utils.normalize_method()

        user = extract_user(conn)

        reverse_controller(path, method)
        |> controller_can?(user, params)
      end

      defp extract_user(conn) do
        apply(unquote(user_extractor), :extract, [conn])
      end

      defp reverse_controller(path, method) do
        [path | _] = String.split(path, "?")

        get_router()
        |> Phoenix.Router.route_info(method, path, "")
      end

      defp get_router() do
        unquote(lazy_router).()
      end

      defp controller_can?(%{plug: controller, plug_opts: phoenix_action}, user, params) do
        params_map =
          Keyword.drop(params, [:method])
          |> Map.new()

        apply(controller, :can?, [user, phoenix_action, params_map])
      end
    end
  end
end
