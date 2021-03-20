defmodule ExcmsCoreWeb.Phoenix.Router do
  @moduledoc false

  defmacro __using__(_opts \\ []) do
    quote do
      import unquote(__MODULE__), only: [excms_core_routes: 0, excms_core_cms_routes: 0]
    end
  end

  @doc false
  defmacro excms_core_routes do
    quote location: :keep do
      scope "/", ExcmsAccountWeb do

      end
    end
  end

  @doc false
  defmacro excms_core_cms_routes do
    quote location: :keep do
      get "/", ExcmsCoreWeb.Cms.PageController, :index
    end
  end
end
