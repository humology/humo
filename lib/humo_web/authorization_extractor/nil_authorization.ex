defmodule HumoWeb.AuthorizationExtractor.NilAuthorization do
  @behaviour HumoWeb.AuthorizationExtractor.Behaviour

  @impl true
  def extract(_conn) do
    nil
  end
end
