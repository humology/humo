defmodule ExcmsCore.RouterHelpers do
  @moduledoc false

  @doc """
  Returns router helpers
  Used to avoid warning of not existing [app].Router.Helpers file for all plugins
  """
  def routes(), do: ExcmsCore.router_helpers()
end
