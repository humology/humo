defmodule ExcmsCoreWeb.AccessRoute do
  alias ExcmsCore.Authorization

  @doc """
  Does authorization has enough permissions
  """
  def permitted?(authorization, "/" <> _ = path, method) do
    required_permissions = path_permissions(path, method)
    Authorization.permitted?(authorization, required_permissions)
  end

  @doc """
  Returns controller permissions by path and action
  """
  def path_permissions(path, method) do
    route_info(path, method)
    |> route_permissions()
  end

  defp route_info(path, method) do
    [path | _] = String.split(path, "?")

    Phoenix.Router.route_info(ExcmsServer.Router, method, path, "")
  end

  defp route_permissions(%{plug: controller, plug_opts: phoenix_action}) do
    if function_exported?(controller, :required_permissions, 1) do
      controller.required_permissions(phoenix_action)
    else
      []
    end
  end
end
