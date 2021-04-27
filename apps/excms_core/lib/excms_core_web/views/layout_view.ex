defmodule ExcmsCoreWeb.LayoutView do
  use ExcmsCoreWeb, :view

  def cms_plugins_menu() do
    Application.fetch_env!(:excms_core, :plugins)
    |> Enum.reject(fn {_, data} -> Map.get(data, :cms_links, []) == [] end)
    |> Enum.map(fn {_, data} ->
      links =
        for link <- data.cms_links do
          link_opts = [ExcmsServer.Endpoint, link.action | Map.get(link, :opts, [])]

          %{
            title: link.title,
            path: apply(routes(), link.route, link_opts),
            method: Map.get(link, :method, "GET")
          }
        end

      %{title: data.title, links: links}
    end)
  end

  def account_links() do
    Application.fetch_env!(:excms_core, :plugins)
    |> Enum.reject(fn {_, data} -> Map.get(data, :account_links, []) == [] end)
    |> Enum.flat_map(fn {_, data} ->
      for link <- data.account_links do
        link_opts = [ExcmsServer.Endpoint, link.action | Map.get(link, :opts, [])]

        %{
          title: link.title,
          path: apply(routes(), link.route, link_opts),
          method: Map.get(link, :method, "GET")
        }
      end
    end)
  end
end
