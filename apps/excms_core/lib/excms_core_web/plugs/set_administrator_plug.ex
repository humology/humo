defmodule ExcmsCoreWeb.SetAdministratorPlug do
  import Plug.Conn
  alias ExcmsCore.Authorization

  def init(opts), do: opts

  def call(conn, _opts) do
    assign(conn, :authorization, %Authorization{is_administrator: true})
  end
end
