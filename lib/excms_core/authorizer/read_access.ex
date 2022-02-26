defmodule ExcmsCore.Authorizer.ReadAccess do
  use ExcmsCore.Authorizer.Behaviour
  alias ExcmsCore.Repo

  @read_action "read"

  @moduledoc """
  ReadAccess policy gives read access to all resources
  """

  @impl true
  def can_all(_user, action, resource_module) do
    if action == @read_action and can_read?(resource_module) do
      resource_module
    else
      Repo.none(resource_module)
    end
  end

  @impl true
  def can_actions(user, %{__struct__: resource_module}) do
    can_actions(user, resource_module)
  end

  def can_actions(_user, resource_module) when is_atom(resource_module) do
    if can_read?(resource_module) do
      [@read_action]
    else
      []
    end
  end

  defp can_read?(resource_module) do
    @read_action in resource_actions(resource_module)
  end
end
