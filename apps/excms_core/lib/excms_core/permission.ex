defmodule ExcmsCore.Permission do
  @moduledoc false
  alias ExcmsCore.Warehouse
  require Logger

  @default_no_access_level "no"

  defstruct resource: nil,
            helpers: nil,
            action: nil,
            access_level: nil

  def new(resource, action, access_level \\ nil)
      when is_atom(resource) and resource != nil and is_binary(action) and
             (is_binary(access_level) or access_level == nil) do
    helpers = Warehouse.resource_to_helpers(resource)

    access_level = access_level || get_minimal_access_level(helpers, action)

    res = %__MODULE__{
      resource: resource,
      helpers: helpers,
      action: action,
      access_level: access_level
    }

    :ok = validate(res)

    res
  end

  defp get_minimal_access_level(nil, _action), do: nil

  defp get_minimal_access_level(helpers, action) do
    ["no", minimal | _] = helpers.access_levels(action)
    minimal
  end

  def validate(%__MODULE__{} = permission) do
    cond do
      permission.helpers == nil ->
        {:error, :undefined_helpers}

      permission.action not in permission.helpers.actions() ->
        {:error, :unknown_action}

      permission.access_level not in permission.helpers.access_levels(permission.action) ->
        {:error, :unknown_access_level}

      true ->
        :ok
    end
  end

  @doc """
  Union permissions
  """
  def union(all_permissions) when is_list(all_permissions) do
    all_permissions
    |> List.flatten()
    |> Enum.group_by(fn x -> {x.helpers, x.action} end)
    |> Enum.map(fn {{helpers, action}, permissions} when is_atom(helpers) and is_binary(action) ->
      access_levels =
        helpers.access_levels(action)
        |> Enum.with_index()
        |> Map.new()

      Enum.max_by(permissions, fn x -> Map.fetch!(access_levels, x.access_level) end)
    end)
  end

  def subset?(required_permissions, permissions) do
    required_permissions
    |> Enum.reject(fn x -> x.access_level == @default_no_access_level end)
    |> Enum.all?(fn required_permission ->
      permission =
        Enum.find(permissions, fn x ->
          resource = x.resource
          action = x.action
          match?(%{resource: ^resource, action: ^action}, required_permission)
        end)

      with true <- not is_nil(permission) do
        access_levels =
          permission.helpers.access_levels(permission.action)
          |> Enum.with_index()
          |> Map.new()

        index = Map.fetch!(access_levels, permission.access_level)
        required_index = Map.fetch!(access_levels, required_permission.access_level)
        index >= required_index
      end
    end)
  end
end
