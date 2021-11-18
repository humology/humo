defmodule Mix.Tasks.Excms.Assets.Gen do
  use Mix.Task
  alias Excms.Deps

  @server_otp_app :excms_server

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

    File.write!("assets/js/app.js", res)
  end

  def deps_assets(subpath, keep_subpath \\ false) do
    deps =
      Deps.ordered_apps(@server_otp_app)
      |> Enum.reject(fn x -> x.app == @server_otp_app end)
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
