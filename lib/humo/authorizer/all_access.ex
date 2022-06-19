defmodule Humo.Authorizer.AllAccess do
  use Humo.Authorizer.Behaviour

  @moduledoc """
  AllAccess policy gives all access to all resources
  """

  @impl true
  def can_all(_authorization, _action, resource_module) do
    resource_module
  end

  @impl true
  def can_actions(_authorization, %resource_module{}) do
    resource_actions(resource_module)
  end

  def can_actions(_authorization, {:list, resource_module})
      when is_atom(resource_module) do
    resource_actions(resource_module)
  end

  def can_actions(_authorization, resource_module)
      when is_atom(resource_module) do
    resource_actions(resource_module)
  end
end
