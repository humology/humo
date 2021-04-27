defmodule ExcmsCoreWeb.Cms.PageController do
  use ExcmsCoreWeb, :controller

  alias ExcmsCore.GlobalAccess

  def required_permissions(_phoenix_action), do: [Permission.new(GlobalAccess, "cms")]

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
