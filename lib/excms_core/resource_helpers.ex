defmodule ExcmsCore.ResourceHelpers do
  defmacro __using__(_opts) do
    quote do
      @behaviour ExcmsCore.ResourceHelpers

      @type action() :: String.t()

      @doc """
      Returns resource name.
      """
      @spec name() :: String.t()
      def name() do
        raise "Method is not implemented."
      end

      @doc """
      Returns list of actions
      """
      @spec actions() :: nonempty_list(action())
      def actions(), do: ["create", "read", "update", "delete"]

      defoverridable name: 0, actions: 0
    end
  end

  @type action() :: String.t()

  @doc """
  Returns resource name.
  """
  @callback name() :: String.t()

  @doc """
  Returns list of actions
  """
  @callback actions() :: nonempty_list(action())
end
