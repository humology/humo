defmodule ExcmsCoreWeb.PageController do
  use ExcmsCoreWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
