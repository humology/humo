defmodule ExcmsCore do
  @moduledoc """
  ExcmsCore keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  alias Ecto.Migrator

  require Logger

  @config Application.compile_env!(:excms_core, __MODULE__)
  @server_app Keyword.fetch!(@config, :server_app)
  @ordered_apps Keyword.fetch!(@config, :deps)
  @server_app_namespace "Elixir.#{Macro.camelize(to_string(@server_app))}"
  @router :"#{@server_app_namespace}.Router"
  @router_helpers :"#{@server_app_namespace}.Router.Helpers"
  @endpoint :"#{@server_app_namespace}.Endpoint"

  def server_app(), do: @server_app

  def ordered_apps(), do: @ordered_apps

  def router(), do: @router

  def router_helpers(), do: @router_helpers

  def endpoint(), do: @endpoint

  def migrate() do
    {:ok, _, _} =
      Migrator.with_repo(ExcmsCore.Repo, fn repo ->
        for dir <- migration_dirs(),
            do: Migrator.run(repo, dir, :up, all: true)
      end)
  end

  defp migration_dirs() do
    dirs = ordered_apps()
           |> Enum.flat_map(&[Application.app_dir(&1.app, ["priv", "repo", "migrations"])])
           |> Enum.filter(&File.dir?/1)

    Logger.debug("Migration dirs #{inspect(dirs, pretty: true, width: 0, limit: :infinity)}")

    dirs
  end
end
