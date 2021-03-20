defmodule ExcmsCoreWeb.Authorizer.Resource do
  alias ExcmsCore.CmsAccess

  @actions_methods %{
    index: "GET",
    edit: "GET",
    new: "GET",
    show: "GET",
    create: "POST",
    update: "PATCH",
    delete: "DELETE"
  }

  @action_permission_type %{
    index: :read,
    edit: :update,
    new: :create,
    show: :read,
    create: :create,
    update: :update,
    delete: :delete
  }

  @doc """
  Returns all resources
  """
  def list_resources() do
    list_controllers()
    |> Enum.flat_map(&get_controller_tables/1)
    |> Enum.sort()
    |> Enum.uniq()
  end

  @doc """
  Returns controller permissions by action
  """
  def get_permissions(path, action) do
    type = permission_type(action)

    path
    |> get_controller(action)
    |> get_controller_permissions(type)
    |> add_cms_access(path, action)
  end

  defp add_cms_access(permissions, "/cms/" <> _, action) do
    permissions
    |> Enum.concat([{permission_type(action), CmsAccess}])
  end
  defp add_cms_access(permissions, "/cms", action) do
    add_cms_access(permissions, "/cms/", action)
  end
  defp add_cms_access(permissions, _path, _action) do
    permissions
  end

  defp list_controllers() do
    apply(ExcmsServer.Router, :__routes__, [])
    |> Enum.map(&(&1.plug))
  end

  defp get_controller_permissions(controller, type) do
    case function_exported?(controller, :permissions, 1) do
      true  ->
        apply(controller, :permissions, [type])
      false ->
        []
    end
  end

  defp get_controller_tables(controller) do
    [:create, :read, :update, :delete]
    |> Enum.flat_map(&(get_controller_permissions(controller, &1)))
    |> Enum.map(&get_permission_resource/1)
    |> Enum.concat([CmsAccess])
    |> Enum.uniq()
    |> Enum.map(&get_resource_table/1)
  end

  defp get_permission_resource({_type, resource}), do: resource

  defp get_resource_table(resource), do: resource.__schema__(:source)

  defp get_controller(path, action) do
    path = String.split(path, "?") |> hd()
    method = action_to_method(action)

    ExcmsServer.Router
    |> Phoenix.Router.route_info(method, path, "")
    |> Map.fetch!(:plug)
  end

  defp action_to_method(action), do: Map.fetch!(@actions_methods, action)

  defp permission_type(action), do: Map.fetch!(@action_permission_type, action)
end
