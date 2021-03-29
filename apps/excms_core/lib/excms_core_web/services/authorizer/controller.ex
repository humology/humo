defmodule ExcmsCoreWeb.Authorizer.Controller do
  defmacro __using__(_opts) do
    quote do
      import ExcmsCoreWeb.RouterHelpers
      plug ExcmsCoreWeb.RequirePermissionsPlug

      @doc """
      Returns permissions by permission type.
      """
      @type action_type :: :create | :read | :update | :delete
      @type resource :: ExcmsCore.Resource.t

      @spec permissions(action_type) :: [{action_type, resource}]
      def permissions(_action_type), do: []

      defoverridable permissions: 1
    end
  end
end
