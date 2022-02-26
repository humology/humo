defmodule ExcmsCore.Authorizer.NoAccess do
  use ExcmsCore.Authorizer.Behaviour
  alias ExcmsCore.Repo

  @moduledoc """
  NoAccess policy gives no access to all resources
  """

  @impl true
  def can_all(_user, _action, resource_module) do
    Repo.none(resource_module)
  end

  @impl true
  def can_actions(_user, _resource_or_module), do: []
end
