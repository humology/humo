defmodule HumoWeb.LayoutView do
  use HumoWeb, :view

  def dashboard_plugins_menu() do
    Application.fetch_env!(:humo, :plugins)
    |> Enum.reject(fn {_, data} -> Map.get(data, :dashboard_links, []) == [] end)
    |> Enum.map(fn {_, data} ->
      links =
        for link <- data.dashboard_links do
          link_opts = [HumoWeb.endpoint(), link.action | Map.get(link, :opts, [])]

          %{
            title: link.title,
            path: apply(routes(), link.route, link_opts),
            method: Map.get(link, :method, :get)
          }
        end

      %{title: data.title, links: links}
    end)
  end

  def account_links() do
    Application.fetch_env!(:humo, :plugins)
    |> Enum.reject(fn {_, data} -> Map.get(data, :account_links, []) == [] end)
    |> Enum.flat_map(fn {_, data} ->
      for link <- data.account_links do
        link_opts = [HumoWeb.endpoint(), link.action | Map.get(link, :opts, [])]

        %{
          title: link.title,
          path: apply(routes(), link.route, link_opts),
          method: Map.get(link, :method, :get)
        }
      end
    end)
  end
end
