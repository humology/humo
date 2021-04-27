defmodule ExcmsCoreWeb.CmsAccessPlug do
  import Plug.Conn
  import Phoenix.Controller
  alias ExcmsCore.Authorization
  alias ExcmsCore.GlobalAccess
  alias ExcmsCore.Permission

  def init(opts), do: opts

  def call(%{assigns: %{authorization: authorization}} = conn, _opts) do
    required_permissions = [Permission.new(GlobalAccess, "cms")]

    if Authorization.permitted?(authorization, required_permissions) do
      conn
    else
      conn
      |> put_flash(:error, "Forbidden")
      |> redirect(to: "/")
      |> halt()
    end
  end
end
