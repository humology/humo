defmodule ExcmsCore.Repo do
  use Ecto.Repo,
    otp_app: :excms_core,
    adapter: Ecto.Adapters.Postgres
end
