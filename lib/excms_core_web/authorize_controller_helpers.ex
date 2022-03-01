defmodule ExcmsCoreWeb.AuthorizeControllerHelpers do
  defmacro __using__(opts) do
    resource_module =
      opts[:resource_module] || raise ":resource_module is expected to be given"
    lazy_authorizer_can =
      opts[:lazy_authorizer_can] || &ExcmsCore.Authorizer.can?/3
    user_extractor =
      opts[:user_extractor] || raise ":user_extractor is expected to be given"

    quote do
      def authorize(conn, _opts) do
        phoenix_action = Phoenix.Controller.action_name(conn)
        user = apply(unquote(user_extractor), :extract, [conn])
        case can?(user, phoenix_action, conn.assigns) do
          true -> conn
          false -> forbidden(conn)
        end
      end

      def forbidden(conn) do
        conn
        |> Plug.Conn.send_resp(403, "Forbidden")
        |> Plug.Conn.halt()
      end

      def can?(user, phoenix_action, params) do
        can_rest?(user, phoenix_action, params)
      end

      def can_rest?(user, phoenix_action, params) do
        case phoenix_action do
          :index -> [user, "read", unquote(resource_module)]
          :show -> [user, "read", params.user]
          :new -> [user, "create", unquote(resource_module)]
          :create -> [user, "create", params.user]
          :edit -> [user, "update", params.user]
          :update -> [user, "update", params.user]
          :delete -> [user, "delete", params.user]
        end
        |> then(&apply(unquote(lazy_authorizer_can), &1))
      end

      plug :authorize

      defoverridable authorize: 2, forbidden: 1, can?: 3, can_rest?: 3
    end
  end
end
