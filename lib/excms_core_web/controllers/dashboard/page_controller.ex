defmodule ExcmsCoreWeb.Dashboard.PageController do
  use ExcmsCoreWeb, :controller

  def can?(_user, :index, _params), do: true

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
