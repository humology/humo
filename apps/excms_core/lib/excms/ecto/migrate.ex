defmodule Mix.Tasks.Excms.Ecto.Migrate do
  use Mix.Task
  alias ExcmsDeps
  alias Ecto.Migrator

  @impl true
  def run(_args) do
    compile_deps()
    migrate()
  end

  def compile_deps() do
    Mix.Task.run("app.start", ["--no-start"])
  end

  def migrate() do
    {:ok, _, _} =
      Migrator.with_repo(ExcmsCore.Repo, fn repo ->
        for dir <- ExcmsDeps.migration_dirs(), do: Migrator.run(repo, dir, :up, all: true)
      end)
  end
end
