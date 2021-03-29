defmodule ExcmsCoreWeb.Authorizer do
  alias ExcmsCoreWeb.Authorizer.Authorization
  alias ExcmsCoreWeb.Authorizer.Warehouse

  @doc """
  Does authorization has enough permissions
  """
  def do?(authorization, path, action), do: Authorization.do?(authorization, path, action)

  @doc """
  Returns all tables names
  """
  def list_resources(), do: Warehouse.list_resources()
end
