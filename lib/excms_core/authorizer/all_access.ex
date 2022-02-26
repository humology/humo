defmodule ExcmsCore.Authorizer.AllAccess do
  use ExcmsCore.Authorizer.Behaviour

  @moduledoc """
  AllAccess policy gives all access to all resources
  """

  @impl true
  def can_all(_user, _action, resource_module) do
    resource_module
  end

  @impl true
  def can_actions(user, %{__struct__: resource_module}) do
    can_actions(user, resource_module)
  end

  def can_actions(_user, resource_module) when is_atom(resource_module) do
    resource_actions(resource_module)
  end
end
