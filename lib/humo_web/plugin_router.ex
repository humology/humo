defmodule HumoWeb.PluginRouter do
  @moduledoc false

  use HumoWeb.PluginRouterBehaviour

  def dashboard() do
    quote location: :keep do
      get "/", HumoWeb.Dashboard.PageController, :index
    end
  end
end
