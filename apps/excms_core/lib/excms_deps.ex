defmodule ExcmsDeps do
  @doc """
  TODO docs
  TODO tests
  """

  require Logger

  @server_otp_app :excms_server

  def migration_dirs() do
    dirs = ordered_apps()
    |> Enum.flat_map(&[Application.app_dir(&1, ["priv", "repo", "migrations"])])
    |> Enum.filter(&File.dir?/1)

    Logger.debug("Migration dirs #{inspect(dirs, pretty: true, width: 0, limit: :infinity)}")

    dirs
  end

  def configs() do
    deps = ordered_apps()

    deps_index = Enum.with_index(deps) |> Map.new()

    umbrella_prefix = get_umbrella_root_prefix()

    config_files = Path.wildcard("#{umbrella_prefix}deps/*/apps/*/config/config.exs")
    |> Enum.concat(Path.wildcard("#{umbrella_prefix}apps/*/config/config.exs"))
    |> Enum.map(fn path ->
      app = Enum.find(deps, fn x -> String.contains?(path, "apps/#{x}/config") end)
      {app, path}
    end)
    |> Enum.reject(fn {app, _} -> is_nil(app) end)
    |> Enum.sort_by(fn {app, _} -> Map.fetch!(deps_index, app) end)
    |> Enum.map(fn {_, path} -> path end)
    |> Enum.map(fn x -> Path.expand(x, ".") end)

    Logger.debug("Import configs in following order")
    for config_file <- config_files do
        Logger.debug("#{config_file} content:")
        Logger.debug(File.read!(config_file))
    end

    config_files
  end

  def deps_assets(subpath \\ "") do
    umbrella_prefix = get_umbrella_root_prefix()

    deps = ordered_apps() -- [@server_otp_app]

    deps_index = Enum.with_index(deps) |> Map.new()

    # deps assets must be copied to root
    Path.wildcard("#{umbrella_prefix}deps/*/assets#{subpath}")
    |> Enum.concat(Path.wildcard("#{umbrella_prefix}apps/*/assets#{subpath}"))
    |> Enum.map(fn path -> String.replace_prefix(path, umbrella_prefix, "") end)
    |> Enum.map(fn path ->
      app = Enum.find(deps, fn x -> String.contains?(path, "/#{x}/assets") end)
      {app, path}
    end)
    |> Enum.reject(fn {app, _} -> is_nil(app) end)
    |> Enum.sort_by(fn {app, _} -> Map.fetch!(deps_index, app) end)
    |> Enum.map(fn {app, path} -> {app, "../../../#{path}"} end)
  end

  defp ordered_apps() do
    apps = Stream.resource(
      fn -> {collect_apps_deps(), MapSet.new()} end,
      fn {apps_deps, known_apps} ->
        unlocked_apps = apps_deps
        |> Enum.filter(fn {_, deps} ->
            MapSet.subset?(deps, known_apps)
        end)
        |> Enum.map(fn {application, _} -> application end)

        case {unlocked_apps, apps_deps} do
          {[], []} -> {:halt, known_apps}
          {[], _} -> raise "Circular dependency"
          _ ->
            new_apps_deps = apps_deps
            |> Enum.reject(fn {application, _} ->
              application in unlocked_apps
            end)

            new_known_apps = unlocked_apps
            |> MapSet.new()
            |> MapSet.union(known_apps)

            {unlocked_apps, {new_apps_deps, new_known_apps}}
        end
      end,
      fn _known_apps -> :ok end)
    |> Enum.to_list()

    Logger.debug("Apps order #{inspect(apps, pretty: true, width: 0, limit: :infinity)}")

    apps
  end

  defp collect_apps_deps() do
    otp_app = get_otp_app()
    umbrella_prefix = get_umbrella_root_prefix(otp_app)
    Stream.resource(
      fn -> {[otp_app], MapSet.new()} end,
      fn
        {[app | rest], known_apps} ->
          deps = get_app_deps(app, umbrella_prefix)
          unknown_apps = Enum.reject(deps, &(&1 in known_apps))
          new_known_apps = MapSet.new([app | unknown_apps]) |> MapSet.union(known_apps)
          {[{app, MapSet.new(deps)}], {unknown_apps ++ rest, new_known_apps}}
        {[], known_apps} ->
          {:halt, known_apps}
      end,
      fn _known_apps -> :ok end)
    |> Enum.to_list()
  end

  defp get_otp_app() do
    if Code.ensure_loaded?(Mix.Project) do
      get_app_from_mix("mix.exs", @server_otp_app)
    else
      @server_otp_app
    end
  end

  defp get_app_deps(app, umbrella_prefix) do
    if Code.ensure_loaded?(Mix.Project) do
      file = Enum.find([
        "#{umbrella_prefix}deps/#{app}/apps/#{app}/mix.exs",
        "#{umbrella_prefix}apps/#{app}/mix.exs"
      ], &File.exists?/1)

      if file != nil do
        get_deps_from_mix(file)
      else
        #ignore dependencies without mix.exs
        []
      end
    else
      Application.spec(app, :applications)
    end
  end

  def get_umbrella_root_prefix() do
    get_umbrella_root_prefix(get_otp_app())
  end

  def get_umbrella_root_prefix(otp_app) do
    with true <- Code.ensure_loaded?(Mix.Project),
         true <- String.ends_with?(File.cwd!(), "/apps/#{otp_app}"),
         true <- File.exists?("../../mix.exs") do
      "../../"
    else
      _ -> ""
    end
  end

  defp get_app_from_mix(file, default) do
    get_fun_body(file, :project)
    |> Keyword.get(:app, default)
  end

  defp get_deps_from_mix(file) do
    get_fun_body(file, :deps)
    |> Enum.map(fn
      {app, _} -> app
      {:{}, _, [app, _, params]} ->
        enabled_envs = Keyword.get(params, :only, Mix.env()) |> List.wrap()
        if Mix.env() in enabled_envs do
          app
        else
          nil
        end
    end)
    |> Enum.reject(&is_nil/1)
    |> MapSet.new()
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
