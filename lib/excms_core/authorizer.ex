defmodule ExcmsCore.Authorizer do
  @behaviour ExcmsCore.Authorizer.Behaviour

  @impl true
  def can?(authorization, action, resource_or_module) do
    authorizer().can?(authorization, action, resource_or_module)
  end

  @impl true
  def can_all(authorization, action, resource_module) do
    authorizer().can_all(authorization, action, resource_module)
  end

  @impl true
  def can_actions(authorization, resource_or_module) do
    authorizer().can_actions(authorization, resource_or_module)
  end

  defp authorizer() do
    Application.fetch_env!(:excms_core, __MODULE__)[:authorizer]
  end
end
