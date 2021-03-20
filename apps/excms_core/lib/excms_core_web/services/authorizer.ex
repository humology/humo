defmodule ExcmsCoreWeb.Authorizer do
  alias ExcmsCoreWeb.Authorizer.Authorization
  alias ExcmsCoreWeb.Authorizer.Resource

  @doc """
  Does authorization has enough permissions
  """
  def do?(authorization, path, action), do: Authorization.do?(authorization, path, action)

  @doc """
  Returns all tables names
  """
  def list_resources(), do: Resource.list_resources()
end
