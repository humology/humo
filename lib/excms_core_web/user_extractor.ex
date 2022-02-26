defmodule ExcmsCoreWeb.UserExtractor do
  alias ExcmsCoreWeb.UserExtractor.NilUser

  def extract(conn, opts \\ []) do
    apply(user_extractor(opts), :extract, [conn])
  end

  defp user_extractor(opts) do
    Keyword.get(
      opts,
      :user_extractor,
      Application.get_env(__MODULE__, :extractor, NilUser)
    )
  end
end
