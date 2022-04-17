defmodule HumoWeb.AuthorizationExtractor do
  @behaviour HumoWeb.AuthorizationExtractor.Behaviour

  @impl true
  def extract(conn) do
    authorization_extractor().extract(conn)
  end

  defp authorization_extractor() do
    Application.fetch_env!(:humo, __MODULE__)[:extractor]
  end
end
