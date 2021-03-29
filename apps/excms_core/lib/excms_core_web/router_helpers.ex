defmodule ExcmsCoreWeb.RouterHelpers do
  @moduledoc false

  @doc """
  Returns router
  Used to avoid warning of not existing ExcmsServer.Router.Helpers file for all plugins
  """
  def routes(), do: ExcmsServer.Router.Helpers
end
