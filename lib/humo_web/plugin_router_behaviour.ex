defmodule HumoWeb.PluginRouterBehaviour do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      @behaviour HumoWeb.PluginRouterBehaviour

      @doc """
      Root routes
      """
      @impl HumoWeb.PluginRouterBehaviour
      @spec root() :: Macro.t()
      def root do
        quote location: :keep do
        end
      end

      @doc """
      Dashboard routes
      """
      @impl HumoWeb.PluginRouterBehaviour
      @spec dashboard() :: Macro.t()
      def dashboard do
        quote location: :keep do
        end
      end

      @doc """
      When used, dispatch to the appropriate router.
      """
      defmacro __using__(which) when is_atom(which) do
        apply(__MODULE__, which, [])
      end

      defoverridable root: 0, dashboard: 0
    end
  end

  @doc """
  Root routes
  """
  @callback root() :: Macro.t()

  @doc """
  Dashboard routes
  """
  @callback dashboard() :: Macro.t()
end
