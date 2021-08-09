defmodule ExcmsCoreWeb.AccessRoute do
  alias ExcmsCore.Permission

  @doc """
  Has enough permissions?
  """
  def permitted?(permissions, "/" <> _ = path, method) do
    method = Plug.Router.Utils.normalize_method(method)
    required_permissions = path_permissions(path, method)
    Permission.permitted?(required_permissions, permissions)
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
