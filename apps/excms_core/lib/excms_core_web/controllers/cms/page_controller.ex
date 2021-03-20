defmodule ExcmsCoreWeb.Cms.PageController do
  use ExcmsCoreWeb, :controller

  alias ExcmsCore.CmsAccess

  def permissions(type), do: [{type, CmsAccess}]

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
