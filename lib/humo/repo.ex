defmodule Humo.Repo do
  use Ecto.Repo,
    otp_app: :humo,
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
