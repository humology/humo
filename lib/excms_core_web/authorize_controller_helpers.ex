defmodule ExcmsCoreWeb.AuthorizeControllerHelpers do
  defmacro __using__(opts) do
    resource_module =
      opts[:resource_module] ||
      raise ":resource_module is expected to be given"

    resource_assign_key =
      opts[:resource_assign_key] ||
      raise ":resource_assign_key is expected to be given"

    authorizer =
      opts[:authorizer] || ExcmsCore.Authorizer

    authorization_extractor =
      opts[:authorization_extractor] || ExcmsCoreWeb.AuthorizationExtractor

    if Mix.env() != :test do
      opts[:authorizer] &&
        raise ":authorizer can be changed only in test env"

      opts[:authorization_extractor] &&
        raise ":authorization_extractor can be changed only in test env"
    end

    quote do
      @type phoenix_action() :: atom()
      @type action() :: ExcmsCore.Authorizer.Behaviour.action()
      @type resource() :: ExcmsCore.Authorizer.Behaviour.resource()
      @type permission() :: {action(), resource()}

      @doc """
      Plug authorizes controller actions
      If authorization fails forbidden error is returned
      """
      @spec authorize(Plug.Conn.t(), Plug.opts()) :: Plug.Conn.t()
      def authorize(conn, _opts) do
        phoenix_action = Phoenix.Controller.action_name(conn)
        if can?(conn, phoenix_action) do
          conn
        else
          conn
          |> Plug.Conn.send_resp(403, "Forbidden")
          |> Plug.Conn.halt()
        end
      end

      @doc """
      Plug authorizes controller actions
      If authorization fails forbidden error is returned
      """
      @spec can?(Plug.Conn.t(), phoenix_action()) :: boolean()
      def can?(conn, phoenix_action) do
        match_required_permissions?(conn, phoenix_action)
      end

      @doc """
      Returns whether request matches requires permissions
      Not overridable, available for use
      """
      @spec match_required_permissions?(Plug.Conn.t(), phoenix_action()) :: boolean()
      def match_required_permissions?(conn, phoenix_action) do
        authorization = unquote(authorization_extractor).extract(conn)

        required_permissions(phoenix_action, conn.assigns)
        |> List.wrap()
        |> Enum.all?(fn {action, resource} ->
          unquote(authorizer).can?(authorization, action, resource)
        end)
      end

      @doc """
      Returns required permission(s)
      """
      @spec required_permissions(phoenix_action(), map()) :: permission() | list(permission())
      def required_permissions(phoenix_action, assigns) do
        required_rest_permissions(phoenix_action, assigns)
      end

      @doc """
      Returns required permission(s)
      Not overridable, available for use
      """
      @spec required_rest_permissions(phoenix_action(), map()) :: permission() | list(permission())
      def required_rest_permissions(phoenix_action, assigns) do
        case phoenix_action do
          :index -> {"read", {:list, unquote(resource_module)}}
          :show -> {"read", Map.fetch!(assigns, unquote(resource_assign_key))}
          :new -> {"create", unquote(resource_module)}
          :create -> {"create", unquote(resource_module)}
          :edit -> {"update", Map.fetch!(assigns, unquote(resource_assign_key))}
          :update -> {"update", Map.fetch!(assigns, unquote(resource_assign_key))}
          :delete -> {"delete", Map.fetch!(assigns, unquote(resource_assign_key))}
        end
      end

      plug :authorize

      defoverridable can?: 2, required_permissions: 2
    end
  end
end
