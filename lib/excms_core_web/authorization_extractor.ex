defmodule ExcmsCoreWeb.AuthorizationExtractor do
  @behaviour ExcmsCoreWeb.AuthorizationExtractor.Behaviour

  @impl true
  def extract(conn) do
    authorization_extractor().extract(conn)
  end

  defp authorization_extractor() do
    Application.fetch_env!(:excms_core, __MODULE__)[:extractor]
  end
end
