defmodule Deps.Config.Gen do
  def generate() do
    environments = [:test, :dev, :prod]

    for env <- environments do
      {_, all_deps} = apps_deps = ordered_apps(env)

      config_files =
        all_deps
        |> Enum.map(fn {_, app_path} ->
          Path.join(app_path, "config/plugin.exs")
        end)
        |> Enum.filter(&File.exists?/1)

      res = render(apps_deps, config_files)

      File.write!("config/#{env}_deps.exs", res)
    end
  end

  defp render({otp_app, deps}, config_files) do
    formatted_deps =
      deps
      |> Enum.map(fn {app, path} -> "    #{inspect(%{app: app, path: path})}" end)
      |> Enum.join(",\n")
      |> case do
           "" -> "[]"
           deps_string -> "[\n#{deps_string}\n  ]"
         end

    deps_imports =
      config_files
      |> Enum.map(fn x ->
        config_path = inspect("../#{x}")
        """
        if Path.expand(#{config_path}, __DIR__) |> File.exists?(), do:
          import_config #{config_path}
        """
      end)
      |> Enum.join("\n")
      |> String.trim()

    """
    import Config

    config #{inspect(otp_app)}, Excms.Deps,
      deps: #{formatted_deps}

    #{deps_imports}
    """
  end

  defp ordered_apps(env) do
    otp_app = fetch_app_from_mix!("./")

    apps =
      Stream.resource(
        fn -> {collect_apps_deps({otp_app, "./"}, env), MapSet.new()} end,
        fn {apps_deps, known_apps} ->
          unlocked_apps =
            apps_deps
            |> Enum.filter(fn {_, deps} ->
              MapSet.subset?(deps, known_apps)
            end)
            |> Enum.map(fn {application, _} -> application end)

          case {unlocked_apps, apps_deps} do
            {[], []} ->
              {:halt, known_apps}

            {[], _} ->
              raise "Circular dependency"

            _ ->
              new_apps_deps =
                apps_deps
                |> Enum.reject(fn {application, _} ->
                  application in unlocked_apps
                end)

              new_known_apps =
                unlocked_apps
                |> MapSet.new()
                |> MapSet.union(known_apps)

              {unlocked_apps, {new_apps_deps, new_known_apps}}
          end
        end,
        fn _known_apps -> :ok end
      )
      |> Enum.to_list()

    {otp_app, apps}
  end

  defp collect_apps_deps(otp_app, env) do
    Stream.resource(
      fn -> {[otp_app], MapSet.new()} end,
      fn
        {[app | rest], known_apps} ->
          deps = get_app_deps(app, env)
          unknown_apps = Enum.reject(deps, &(&1 in known_apps))
          new_known_apps = MapSet.new([app | unknown_apps]) |> MapSet.union(known_apps)
          {[{app, MapSet.new(deps)}], {unknown_apps ++ rest, new_known_apps}}

        {[], known_apps} ->
          {:halt, known_apps}
      end,
      fn _known_apps -> :ok end
    )
    |> Enum.to_list()
  end

  defp get_app_deps({_, app_path}, env) do
    if Path.join(app_path, "mix.exs") |> File.exists?() do
      get_deps_from_mix(app_path, env)
    else
      # ignore dependencies without mix.exs
      []
    end
  end

  defp fetch_app_from_mix!(app_path) do
    get_mix_fun_body(app_path, :project)
    |> Keyword.fetch!(:app)
  end

  defp is_humo_plugin?(app_path) do
    if Path.join(app_path, "mix.exs") |> File.exists?() do
      get_mix_fun_body(app_path, :project)
      |> Keyword.get(:humo_plugin, false)
    else
      # ignore dependencies without mix.exs
      false
    end
  end

  defp get_deps_from_mix(app_path, env) do
    get_mix_fun_body(app_path, :deps)
    |> Enum.map(fn x ->
      {app, params} =
        case x do
          {:{}, _, [app, _, params]} ->
            {app, params}
          {app, params} when is_list(params) ->
            {app, params}
          {app, _} ->
            {app, []}
        end

      app_path =
        params
        |> Keyword.get(:path, "deps/#{app}/")

      allowlist_envs =
        params
        |> Keyword.get(:only, env)
        |> List.wrap()

      if env in allowlist_envs do
        {app, app_path}
      else
        nil
      end
    end)
    |> Enum.reject(&is_nil/1)
    |> Enum.filter(fn {_, app_path} -> is_humo_plugin?(app_path) end)
    |> MapSet.new()
  end

  defp get_mix_fun_body(app_path, fun_name) do
    mix_path = Path.join(app_path, "mix.exs")
    {:ok, {_, _, [_, [do: {_, _, functions}]]}} =
      File.read!(mix_path)
      |> Code.string_to_quoted()

    {_, _, [_, [{:do, quoted_body}]]} =
      Enum.find(functions, fn x -> match?({_, _, [{^fun_name, _, _}, _]}, x) end)

    quoted_body
  end
end

Deps.Config.Gen.generate()
