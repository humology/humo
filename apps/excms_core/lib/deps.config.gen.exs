defmodule Deps.Config.Gen do
  def generate() do
    check_umbrella_application!("mix.exs")

    environments = [:test, :dev, :prod]

    for env <- environments do
      apps_deps =
        Path.wildcard("../../apps/*/mix.exs")
        |> Enum.map(&ordered_apps(&1, env))

      all_deps =
        apps_deps
        |> Enum.map(fn {_, deps} -> deps end)
        |> Enum.concat()
        |> Enum.uniq()

      config_files =
        all_deps
        |> Enum.map(fn app ->
          ["deps/#{app}/apps/#{app}/config/config.exs", "apps/#{app}/config/config.exs"]
          |> Enum.find(fn x -> File.exists?("../../"<>x) end)
        end)
        |> Enum.reject(&is_nil/1)

      res = render(apps_deps, config_files)

      File.write!("../../config/#{env}_deps.exs", res)
    end
  end

  defp render(apps_deps, config_files) do
    deps_config =
      apps_deps
      |> Enum.map(fn {app, deps} ->
        formatted_deps =
          deps
          |> Enum.map(fn x -> "    #{inspect(x)}" end)
          |> Enum.join(",\n")
          |> case do
               "" -> "[]"
               deps -> "[\n#{deps}\n  ]"
             end

        "config #{inspect(app)}, Excms.Deps,\n  deps: #{formatted_deps}"
      end)
      |> Enum.join("\n\n")

    deps_imports =
      config_files
      |> Enum.map(fn x ->
        config_path = inspect("../"<>x)
        """
        if Path.expand(#{config_path}, __DIR__) |> File.exists?(), do:
          import_config #{config_path}
        """
      end)
      |> Enum.join("\n")
      |> String.trim()

    """
    import Config

    #{deps_config}

    #{deps_imports}
    """
  end

  defp ordered_apps(mix_path, env) do
    otp_app = fetch_app_from_mix!(mix_path)

    apps =
      Stream.resource(
        fn -> {collect_apps_deps(otp_app, env), MapSet.new()} end,
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

  defp check_umbrella_application!(mix_path) do
    deps_path =
      get_mix_fun_body(mix_path, :project)
      |> Keyword.fetch!(:deps_path)

    if deps_path != "../../deps" do
      raise "#{__MODULE__} can be run only from umbrella application"
    end
  end

  defp get_app_deps(app, env) do
    file =
      ["../../deps/#{app}/apps/#{app}/mix.exs", "../../apps/#{app}/mix.exs"]
      |> Enum.find(&File.exists?/1)

    if file != nil do
      get_deps_from_mix(file, env)
    else
      # ignore dependencies without mix.exs
      []
    end
  end

  defp fetch_app_from_mix!(mix_path) do
    get_mix_fun_body(mix_path, :project)
    |> Keyword.fetch!(:app)
  end

  defp get_deps_from_mix(mix_path, env) do
    get_mix_fun_body(mix_path, :deps)
    |> Enum.map(fn
      {app, _} ->
        app

      {:{}, _, [app, _, params]} ->
        allowlist_envs =
          params
          |> Keyword.get(:only, env)
          |> List.wrap()

        case env in allowlist_envs do
          true -> app
          false -> nil
        end
    end)
    |> Enum.reject(&is_nil/1)
    |> MapSet.new()
  end

  defp get_mix_fun_body(mix_path, fun_name) do
    {:ok, {_, _, [_, [do: {_, _, functions}]]}} =
      File.read!(mix_path)
      |> Code.string_to_quoted()

    {_, _, [_, [{:do, quoted_body}]]} =
      Enum.find(functions, fn x -> match?({_, _, [{^fun_name, _, _}, _]}, x) end)

    quoted_body
  end
end

Deps.Config.Gen.generate()
