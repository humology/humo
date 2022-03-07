defmodule ExcmsCoreWeb.AuthorizationExtractor.Behaviour do
  @doc """
  Extract authorization from Plug.Conn
  """
  @callback extract(Plug.Conn.t()) :: any()
end
