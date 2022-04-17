defmodule HumoWeb.Routers.Dashboard do
  @moduledoc false

  defmacro __using__(_opts) do
    quote location: :keep do
      get "/", HumoWeb.Dashboard.PageController, :index
    end
  end
end
