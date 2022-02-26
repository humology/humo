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
      Returns localized title.
      """
      @spec title() :: String.t()
      def title(), do: String.capitalize(name())

      @doc """
      Returns localized description.
      """
      @spec description() :: String.t()
      def description(), do: "#{title()} has no description"

      @doc """
      Returns list of actions
      """
      @spec actions() :: nonempty_list(action())
      def actions(), do: ["create", "read", "update", "delete"]

      defoverridable name: 0, title: 0, description: 0, actions: 0
    end
  end

  @type action() :: String.t()

  @doc """
  Returns resource name.
  """
  @callback name() :: String.t()

  @doc """
  Returns localized title.
  """
  @callback title() :: String.t()

  @doc """
  Returns localized description.
  """
  @callback description() :: String.t()

  @doc """
  Returns list of actions
  """
  @callback actions() :: nonempty_list(action())
end
