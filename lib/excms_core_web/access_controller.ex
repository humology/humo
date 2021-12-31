defmodule ExcmsCoreWeb.AccessController do
  defmacro __using__(_opts) do
    quote do
      import ExcmsCore.RouterHelpers
      plug ExcmsCoreWeb.AccessPlug

      @type rest_action :: String.t()
      @type phoenix_action :: atom()
      @type permission :: ExcmsCore.Permission.t()

      @phoenix_action_to_rest_action %{
        index: "read",
        edit: "update",
        new: "create",
        show: "read",
        create: "create",
        update: "update",
        delete: "delete"
      }

      @doc """
      Returns required permissions by phoenix action.
      Default implementation works for rest actions.
      """
      @spec required_permissions(phoenix_action) :: list(permission)
      def required_permissions(phoenix_action) do
        @phoenix_action_to_rest_action
        |> Map.fetch!(phoenix_action)
        |> rest_permissions()
      end

      @doc """
      Returns rest permissions by rest action.
      """
      @spec rest_permissions(rest_action) :: list(permission)
      def rest_permissions(rest_action), do: []

      defoverridable required_permissions: 1, rest_permissions: 1
    end
  end
end
