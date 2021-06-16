defmodule Mix.Tasks.Excms.Assets.Compile do
  use Mix.Task
  alias ExcmsDeps

  @impl true
  def run(_args) do
    compile_deps()
    create_copy_static_assets()
    update_package_json()
    create_app_js()
  end

  defp compile_deps() do
    Mix.Task.run("app.start", ["--no-start"])
  end

  defp create_copy_static_assets() do
    dirs =
      ExcmsDeps.deps_assets("/static")
      |> Enum.map(fn {_app, dir} -> dir end)

    json_config =
      dirs
      |> Enum.with_index()
      |> Enum.map(fn {dir, index} ->
        %{
          from: dir,
          to: "../",
          priority: index,
          force: index != 0
        }
      end)
      |> Jason.encode!(pretty: true)

    umbrella_prefix = ExcmsDeps.get_umbrella_root_prefix()

    filepath = "#{umbrella_prefix}apps/excms_server/assets/copy-static-assets.json"

    File.write!(filepath, json_config)
  end

  defp update_package_json() do
    umbrella_prefix = ExcmsDeps.get_umbrella_root_prefix()
    deps_assets =
      ExcmsDeps.deps_assets("/package.json")
      |> Enum.map(fn {app, path} ->
        {app, String.replace_suffix(path, "/package.json", "")}
      end)

    filepath = "#{umbrella_prefix}apps/excms_server/assets/package.json"

    package =
      File.read!(filepath)
      |> Jason.decode!()

    dependencies =
      deps_assets
      |> Enum.reduce(%{}, fn {app, dir}, acc ->
        Map.put(acc, "#{app}", "file:#{dir}")
      end)

    res =
      package
      |> Map.put("dependencies", dependencies)
      |> Jason.encode!(pretty: true)

    File.write!(filepath, res)
  end

  defp create_app_js() do
    umbrella_prefix = ExcmsDeps.get_umbrella_root_prefix()
    deps_assets =
      ExcmsDeps.deps_assets("/package.json")
      |> Enum.map(fn {app, path} ->
        {app, String.replace_suffix(path, "/package.json", "")}
      end)

    filepath = "#{umbrella_prefix}apps/excms_server/assets/js/app.js"

    res =
      deps_assets
      |> Enum.map(fn {app, _} -> "import \"#{app}\"\n" end)
      |> Enum.join("")

    File.write!(filepath, res)
  end
end
