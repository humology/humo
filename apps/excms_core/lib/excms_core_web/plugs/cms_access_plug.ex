defmodule ExcmsCoreWeb.CmsAccessPlug do
  import Plug.Conn
  import Phoenix.Controller
  alias ExcmsCore.GlobalAccess
  alias ExcmsCore.Permission

  def init(opts), do: opts

  def call(%{assigns: %{permissions: permissions}} = conn, _opts) do
    required_permissions = [Permission.new(GlobalAccess, "cms")]

    if Permission.permitted?(required_permissions, permissions) do
      conn
    else
      conn
      |> put_flash(:error, "Forbidden")
      |> redirect(to: "/")
      |> halt()
    end
  end
end
