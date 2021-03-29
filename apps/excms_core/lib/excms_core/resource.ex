defmodule ExcmsCore.Resource do
  defmacro __using__(_opts) do
    quote do
      @doc """
      Returns resource name.
      """
      def resource_name() do
        __MODULE__.__schema__(:source)
      end

      defoverridable resource_name: 0
    end
  end
end

