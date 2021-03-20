defmodule ExcmsCoreWeb.SetAdministratorPlug do
  import Plug.Conn
  alias ExcmsCoreWeb.Authorizer.Authorization

  def init(opts), do: opts

  def call(conn, _opts) do
    conn
    |> assign(:authorization, %Authorization{is_administrator: true})
  end
end
