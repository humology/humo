defmodule ExcmsCoreWeb.RequirePermissionsPlug do
  import Plug.Conn
  import Phoenix.Controller
  alias ExcmsCoreWeb.Authorizer

  def init(opts), do: opts

  def call(conn, _opts) do
    authorization = conn.assigns.authorization
    path = conn.request_path
    action = action_name(conn)

    if Authorizer.do?(authorization, path, action) do
      conn
    else
      conn
      |> put_flash(:error, "No permission")
      |> redirect(to: "/") # TODO should it be another page? prev routes().page_path(conn, :index)
      |> halt()
    end
  end
end
