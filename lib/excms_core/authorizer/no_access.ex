defmodule ExcmsCore.Authorizer.NoAccess do
  use ExcmsCore.Authorizer.Behaviour
  alias ExcmsCore.Repo

  @moduledoc """
  NoAccess policy gives no access to all resources
  """

  @impl true
  def can_all(_authorization, _action, resource_module) do
    Repo.none(resource_module)
  end

  @impl true
  def can_actions(_authorization, _resource), do: []
end
