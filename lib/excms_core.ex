defmodule ExcmsCore do
  @moduledoc """
  ExcmsCore keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  alias Ecto.Migrator

  require Logger

  def server_app(), do:
    Keyword.fetch!(config(), :server_app)

  def is_server_app_module(module) when is_atom(module) do
    hd(Module.split(module)) == Macro.camelize(to_string(server_app()))
  end

  def ordered_apps(), do:
    Keyword.fetch!(config(), :deps)

  def migrate() do
    {:ok, _, _} =
      Migrator.with_repo(ExcmsCore.Repo, fn repo ->
        for dir <- migration_dirs(),
            do: Migrator.run(repo, dir, :up, all: true)
      end)
  end

  defp migration_dirs() do
    dirs =
      ordered_apps()
      |> Enum.flat_map(&[Application.app_dir(&1.app, ["priv", "repo", "migrations"])])
      |> Enum.filter(&File.dir?/1)

    Logger.debug("Migration dirs #{inspect(dirs, pretty: true, width: 0, limit: :infinity)}")

    dirs
  end

  defp config(), do:
    Application.fetch_env!(:excms_core, __MODULE__)
end
