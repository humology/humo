defmodule ExcmsCore.Repo do
  use Ecto.Repo,
    otp_app: :excms_core,
    adapter: Ecto.Adapters.Postgres

  import Ecto.Query, warn: false

  @doc """
  Returns no results from query.

  TODO: Not optimized by ecto, request is made.
  """
  def none(query) do
    from query, where: false
  end
end
