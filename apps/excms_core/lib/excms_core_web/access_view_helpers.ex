defmodule ExcmsCoreWeb.AccessViewHelpers do
  alias ExcmsCoreWeb.AccessRoute
  use Phoenix.HTML

  def permitted_link(conn, opts, do: contents) when is_list(opts),
    do: permitted_link(conn, contents, opts)

  def permitted_link(conn, text, opts) do
    path = Keyword.fetch!(opts, :to)
    method = Keyword.get(opts, :method, "GET")

    if permitted?(conn, path, method) do
      link(text, opts)
    else
      ""
    end
  end

  def permitted?(conn, path, method \\ "GET"),
    do: AccessRoute.permitted?(conn.assigns.authorization, path, method)
end
