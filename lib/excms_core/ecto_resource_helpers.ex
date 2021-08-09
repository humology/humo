defmodule ExcmsCore.EctoResourceHelpers do
  defmacro __using__(_opts) do
    quote do
      use ExcmsCore.ResourceHelpers

      @doc """
      Returns schema name.
      """
      @spec name() :: String.t()
      def name() do
        get_resource_module().__schema__(:source)
      end

      defp get_resource_module() do
        __MODULE__
        |> Atom.to_string()
        |> String.split(".")
        |> Enum.drop(-1)
        |> Module.concat()
      end

      defoverridable name: 0
    end
  end
end
