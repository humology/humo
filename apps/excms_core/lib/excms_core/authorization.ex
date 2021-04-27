defmodule ExcmsCore.Authorization do
  defstruct is_administrator: false,
            permissions: []

  alias ExcmsCore.Permission

  @doc """
  Unions authorizations list
  """
  def union(authorizations) when is_list(authorizations) do
    %__MODULE__{
      is_administrator:
        authorizations
        |> Enum.map(fn x -> x.is_administrator end)
        |> Enum.any?(),
      permissions:
        authorizations
        |> Enum.map(fn x -> x.permissions end)
        |> Permission.union()
    }
  end

  def permitted?(%__MODULE__{is_administrator: true}, _required_permissions), do: true

  def permitted?(%__MODULE__{permissions: permissions}, required_permissions),
    do: Permission.subset?(required_permissions, permissions)
end
