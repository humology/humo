defmodule Excms.Deps do
  @doc """
  TODO docs
  TODO tests
  """

  alias Ecto.Migrator

  require Logger

  @server_otp_app :excms_server

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

  def ordered_apps(), do: ordered_apps(get_otp_app())

  def ordered_apps(otp_app) do
    Application.fetch_env!(otp_app, __MODULE__)
    |> Keyword.fetch!(:deps)
  end

  defp get_otp_app() do
    if Code.ensure_loaded?(Mix.Project) do
      # TODO try get from Mix.Project.config()
      get_app_from_mix("mix.exs", @server_otp_app)
    else
      @server_otp_app
    end
  end

  defp get_app_from_mix(file, default) do
    get_fun_body(file, :project)
    |> Keyword.get(:app, default)
  end

  defp get_fun_body(file, fun_name) do
    {:ok, {_, _, [_, [do: {_, _, functions}]]}} = file
    |> File.read!()
    |> Code.string_to_quoted()

    {_, _, [_ , [{:do, quoted_body}]]} = functions
    |> Enum.find(fn x -> match?({_,_,[{^fun_name, _, _}, _]}, x) end)

    quoted_body
  end
end
