defmodule ExcmsCoreWeb.AccessPlug do
  import Plug.Conn
  import Phoenix.Controller
  alias ExcmsCoreWeb.AccessRoute

  def init(opts), do: opts

  def call(%{assigns: %{authorization: authorization}} = conn, _opts) do
    if AccessRoute.permitted?(authorization, conn.request_path, conn.method) do
      conn
    else
      conn
      |> put_flash(:error, "Forbidden")
      # TODO should it be another page? prev routes().page_path(conn, :index)
      |> redirect(to: "/")
      |> halt()
    end
  end
end