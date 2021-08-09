defmodule ExcmsCore.ResourceHelpers do
  defmacro __using__(_opts) do
    quote do
      @type action() :: String.t()
      @type access_level() :: String.t()

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

      @doc """
      Returns access levels by action
      List must be sorted from least to most

      ## Examples

          iex> access_levels("update")
          ["no", "own", "all"]
      """
      @spec access_levels(action()) :: nonempty_list(access_level())
      def access_levels(_action), do: ["no", "all"]

      defoverridable name: 0, title: 0, description: 0, actions: 0, access_levels: 1
    end
  end
end
