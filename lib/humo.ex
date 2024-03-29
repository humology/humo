defmodule Humo do
  @moduledoc """
  Humo keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  alias Ecto.Migrator

  require Logger

  def otp_app, do: Keyword.fetch!(config(), :otp_app)

  def is_otp_app_module(module) when is_atom(module) do
    hd(Module.split(module)) == Macro.camelize(to_string(otp_app()))
  end

  def ordered_apps, do: Keyword.fetch!(config(), :apps)

  def migrate do
    {:ok, _, _} =
      Migrator.with_repo(Humo.Repo, fn repo ->
        for dir <- migration_dirs(),
            do: Migrator.run(repo, dir, :up, all: true)
      end)
  end

  defp migration_dirs do
    dirs =
      ordered_apps()
      |> Enum.flat_map(&[Application.app_dir(&1.app, ["priv", "repo", "migrations"])])
      |> Enum.filter(&File.dir?/1)

    Logger.debug("Migration dirs #{inspect(dirs, pretty: true, width: 0, limit: :infinity)}")

    dirs
  end

  defp config, do: Application.fetch_env!(:humo, __MODULE__)
end
