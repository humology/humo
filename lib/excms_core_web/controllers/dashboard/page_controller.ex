defmodule ExcmsCoreWeb.Dashboard.PageController do
  use ExcmsCoreWeb, :controller

  alias ExcmsCore.GlobalAccess

  def required_permissions(_phoenix_action), do: [Permission.new(GlobalAccess, "dashboard")]

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
