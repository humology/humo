defmodule Mix.Tasks.Excms.Assets.Gen do
  use Mix.Task

  @impl true
  def run(_args) do
    create_copy_static_assets()
    create_app_js()
  end

  defp create_copy_static_assets() do
    dirs = deps_assets("assets/static", true)

    json_config =
      dirs
      |> Enum.with_index()
      |> Enum.map(fn {%{path: path}, index} ->
        %{
          from: path,
          to: "../",
          priority: index,
          force: index != 0
        }
      end)
      |> Jason.encode!(pretty: true)

    File.write!("assets/copy-static-assets.json", json_config)
  end

  defp create_app_js() do
    res =
      deps_assets("package.json")
      |> Enum.map(fn %{app: app} -> "import \"#{app}\"\n" end)
      |> Enum.join("")

    res = ~s(import "./plugin"\n#{res})

    File.write!("assets/js/app.js", res)
  end

  def deps_assets(subpath, keep_subpath \\ false) do
    server_app = ExcmsCore.server_app()

    deps =
      ExcmsCore.ordered_apps()
      |> Enum.reject(fn x -> x.app == server_app end)
      |> Enum.filter(fn %{path: path} ->
        [path, subpath]
        |> Path.join()
        |> File.exists?()
      end)

    if keep_subpath do
      for %{path: path} = config <- deps do
        %{config | path: Path.join([path, subpath])}
      end
    else
      deps
    end
  end
end
