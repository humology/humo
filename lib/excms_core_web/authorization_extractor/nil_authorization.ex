defmodule ExcmsCoreWeb.AuthorizationExtractor.NilAuthorization do
  @behaviour ExcmsCoreWeb.AuthorizationExtractor.Behaviour

  @impl true
  def extract(_conn) do
    nil
  end
end
