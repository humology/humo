defmodule ExcmsCoreWeb.SetAdministratorPlug do
  import Plug.Conn
  alias ExcmsCore.Permission
  alias ExcmsCore.GlobalAccess

  def init(opts), do: opts

  def call(conn, _opts) do
    assign(conn, :permissions, [Permission.new(GlobalAccess, "administrator", "all")])
  end
end
