defmodule ExcmsCoreWeb.Authorizer.Authorization do
  alias ExcmsCoreWeb.Authorizer.Resource

  defstruct is_administrator: false, permissions: []

  @allowed_actions [:index, :edit, :new, :show, :create, :update, :delete]

  @doc """
  Returns empty authorization
  """
  def new() do
    %__MODULE__{
      is_administrator: false,
      permissions: MapSet.new()
    }
  end

  @doc """
  Joins authorizations list
  """
  def join(authorizations) when is_list(authorizations) do
    Enum.reduce(authorizations, new(), &join/2)
  end

  defp join(authorization1, authorization2) do
    %__MODULE__{
      is_administrator: authorization1.is_administrator or authorization2.is_administrator,
      permissions: MapSet.union(authorization1.permissions, authorization2.permissions)
    }
  end

  @doc """
  Does authorization has enough permissions
  """
  def do?(%__MODULE__{is_administrator: true}, _path, action)
      when action in @allowed_actions, do:
    true

  def do?(%__MODULE__{permissions: permissions}, "/"<>_ = path, action)
      when action in @allowed_actions do
    path
    |> Resource.get_permissions(action)
    |> Enum.map(&serialize_req_permission/1)
    |> MapSet.new()
    |> MapSet.subset?(permissions)
  end

  defp serialize_req_permission({action, resource}), do: {action, get_resource_table(resource)}

  defp get_resource_table(resource), do: resource.__schema__(:source)
end
