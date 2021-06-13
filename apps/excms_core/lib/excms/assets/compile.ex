defmodule Mix.Tasks.Excms.Assets.Compile do
  use Mix.Task
  alias ExcmsDeps
  alias Ecto.Migrator

  @impl true
  def run(_args) do
    compile_deps()
    copy_deps_assets()
    create_copy_static_assets()
    update_package_json()
    create_app_js()
  end

  defp compile_deps() do
    Mix.Task.run("app.start", ["--no-start"])
  end

  @doc """
  Solves problem with package.json dependencies relative path
  from directory apps/app2/assets
  ../../../deps/app1/apps/app1/assets
  from directory deps/app2/apps/app2/assets
  ../../../../../deps/app1/apps/app1/assets - relative path is different

  Solution - put assets in root folder of dependency
  pwd = apps/app2/assets
  ../../../deps/app1/assets
  pwd = deps/app2/assets
  ../../../deps/app1/assets - relative path is equal

  Symlink unfortunately doesn't work, because another symlinks are used inside
  """
  defp copy_deps_assets() do
    Path.wildcard("../../deps/*/apps/*/assets") |> Enum.map(fn source ->
      dest = "#{source}/../../../assets"
      if File.exists?(dest), do: File.rm_rf!(dest)
      File.cp_r!(source, dest)
    end)
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
