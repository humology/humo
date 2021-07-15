defmodule ExcmsCoreWeb.Routers.Dashboard do
  @moduledoc false

  defmacro __using__(_opts) do
    quote location: :keep do
      get "/", ExcmsCoreWeb.Dashboard.PageController, :index
    end
  end
end
