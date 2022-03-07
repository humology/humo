defmodule ExcmsCore.Authorizer.Behaviour do
  defmacro __using__(_opts) do
    quote do
      alias ExcmsCore.Authorizer.Behaviour

      @behaviour Behaviour

      @type authorization() :: Behaviour.authorization()
      @type resource() :: Behaviour.resource()
      @type resource_module() :: Behaviour.resource_module()
      @type resource_or_module() :: Behaviour.resource_or_module()
      @type action() :: Behaviour.action()

      @doc """
      Can authorization do action with provided resource record or module?
      """
      @impl ExcmsCore.Authorizer.Behaviour
      @spec can?(authorization(), action(), resource_or_module()) :: boolean()
      def can?(authorization, action, resource_or_module) do
        action in can_actions(authorization, resource_or_module)
      end

      @doc """
      Returns authorized resource records
      """
      @impl ExcmsCore.Authorizer.Behaviour
      @spec can_all(authorization(), action(), resource_module()) :: any()
      def can_all(_authorization, _action, _resource_module) do
        raise "Method is not implemented."
      end

      @doc """
      Returns authorized actions to provided resource record or module
      """
      @impl ExcmsCore.Authorizer.Behaviour
      @callback can_actions(authorization(), resource_or_module()) :: list(action())
      def can_actions(_authorization, _resource_or_module) do
        raise "Method is not implemented."
      end

      def resource_actions(resource_module) do
        ExcmsCore.Warehouse.resource_to_helpers(resource_module).actions()
      end

      defoverridable can?: 3, can_all: 3, can_actions: 2
    end
  end

  @type authorization() :: struct()
  @type resource() :: struct()
  @type resource_module() :: module()
  @type resource_or_module() :: resource() | resource_module()
  @type action() :: String.t()

  @doc """
  Can authorization do action with provided resource record or module?
  """
  @callback can?(authorization(), action(), resource_or_module()) :: boolean()

  @doc """
  Returns authorized resource records
  """
  @callback can_all(authorization(), action(), resource_module()) :: any()

  @doc """
  Returns authorized actions to provided resource record or module
  """
  @callback can_actions(authorization(), resource_or_module()) :: list(action())
end
