defmodule ExcmsCore.Authorizer.Behaviour do
  defmacro __using__(_opts) do
    quote do
      @behaviour ExcmsCore.Authorizer.Behaviour

      @type user() :: struct()
      @type resource() :: struct()
      @type resource_module() :: module()
      @type resource_or_module() :: resource() | resource_module()
      @type action() :: String.t()

      @doc """
      Can user do action with provided resource record or module?
      """
      @impl ExcmsCore.Authorizer.Behaviour
      @spec can?(user(), action(), resource_or_module()) :: boolean()
      def can?(user, action, resource_or_module) do
        action in can_actions(user, resource_or_module)
      end

      @doc """
      Returns resource records user is authorized to
      """
      @impl ExcmsCore.Authorizer.Behaviour
      @spec can_all(user(), action(), resource_module()) :: any()
      def can_all(_user, _action, _resource_module) do
        raise "Method is not implemented."
      end

      @doc """
      Returns actions authorized to user with provided resource record or module
      """
      @impl ExcmsCore.Authorizer.Behaviour
      @callback can_actions(user(), resource_or_module()) :: list(action())
      def can_actions(_user, _resource_or_module) do
        raise "Method is not implemented."
      end

      def resource_actions(resource_module) do
        ExcmsCore.Warehouse.resource_to_helpers(resource_module).actions()
      end

      defoverridable can?: 3, can_all: 3, can_actions: 2
    end
  end

  @type user() :: struct()
  @type resource() :: struct()
  @type resource_module() :: module()
  @type resource_or_module() :: resource() | resource_module()
  @type action() :: String.t()

  @doc """
  Returns user is authorized to do action with provided resource
  """
  @callback can?(user(), action(), resource_or_module()) :: boolean()

  @doc """
  Returns resource records user is authorized to
  """
  @callback can_all(user(), action(), resource_module()) :: any()

  @doc """
  Returns actions authorized to user with provided resource
  """
  @callback can_actions(user(), resource_or_module()) :: list(action())
end
