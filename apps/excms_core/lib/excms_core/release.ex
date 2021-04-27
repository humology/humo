defmodule ExcmsCore.Release do
  alias ExcmsDeps
  alias Ecto.Migrator

  def migrate() do
    {:ok, _, _} =
      Migrator.with_repo(ExcmsCore.Repo, fn repo ->
        for dir <- ExcmsDeps.migration_dirs(), do: Migrator.run(repo, dir, :up, all: true)
      end)
  end
end
