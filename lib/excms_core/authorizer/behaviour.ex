defmodule ExcmsCore.Authorizer.Behaviour do
  defmacro __using__(_opts) do
    quote do
      alias ExcmsCore.Authorizer.Behaviour
      alias ExcmsCore.Warehouse

      @behaviour Behaviour

      @type authorization() :: Behaviour.authorization()
      @type resource() :: Behaviour.resource()
      @type resource_module() :: Behaviour.resource_module()
      @type action() :: Behaviour.action()

      @doc """
      Can authorization do action with provided resource record or module?
      """
      @impl ExcmsCore.Authorizer.Behaviour
      @spec can?(authorization(), action(), resource()) :: boolean()
      def can?(authorization, action, resource) do
        action in can_actions(authorization, resource)
      end

      @doc """
      Returns actions provided by resource module
      """
      @spec resource_actions(resource_module()) :: list(action())
      def resource_actions(resource_module) do
        Warehouse.resource_helpers(resource_module).actions()
      end

      defoverridable can?: 3
    end
  end

  @type authorization() :: struct()
  @type resource_record() :: struct()
  @type resource_module() :: ExcmsCore.Warehouse.resource_module()
  @type resource() :: resource_record() | resource_module() | {:list, resource_module()}
  @type action() :: String.t()

  @doc """
  Can authorization do action with provided resource?
  """
  @callback can?(authorization(), action(), resource()) :: boolean()

  @doc """
  Returns authorized resource records
  """
  @callback can_all(authorization(), action(), resource_module()) :: any()

  @doc """
  Returns authorized actions to provided resource
  """
  @callback can_actions(authorization(), resource()) :: list(action())
end
