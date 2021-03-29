defmodule ExcmsCoreWeb.Routers.Cms do
  @moduledoc false

  defmacro __using__(_opts) do
    quote location: :keep do
      get "/", ExcmsCoreWeb.Cms.PageController, :index
    end
  end
end
