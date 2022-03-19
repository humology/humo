defmodule ExcmsCore.Authorizer.ReadAccess do
  use ExcmsCore.Authorizer.Behaviour
  alias ExcmsCore.Repo

  @read_action "read"

  @moduledoc """
  ReadAccess policy gives read access to all resources
  """

  @impl true
  def can_all(_authorization, action, resource_module) do
    if action == @read_action and can_read?(resource_module) do
      resource_module
    else
      Repo.none(resource_module)
    end
  end

  @impl true
  def can_actions(_authorization, %{__struct__: resource_module}) do
    authorized_actions(resource_module)
  end

  def can_actions(_authorization, {:list, resource_module})
  when is_atom(resource_module) do
    authorized_actions(resource_module)
  end

  def can_actions(_authorization, resource_module)
  when is_atom(resource_module) do
    authorized_actions(resource_module)
  end

  defp authorized_actions(resource_module) do
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
