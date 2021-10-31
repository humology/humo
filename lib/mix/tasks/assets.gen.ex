defmodule Mix.Tasks.Excms.Assets.Gen do
  use Mix.Task
  alias Excms.Deps

  @server_otp_app :excms_server

  @impl true
  def run(_args) do
    create_copy_static_assets()
    update_package_json()
    create_app_js()
  end

  defp create_copy_static_assets() do
    dirs = deps_assets("assets/static")

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

  defp update_package_json() do
    assets =
      deps_assets("package.json")
      |> Enum.map(fn %{path: path} = config ->
        %{config | path: String.replace_suffix(path, "package.json", "")}
      end)

    filepath = "package.json"

    package =
      File.read!(filepath)
      |> Jason.decode!()

    dependencies =
      assets
      |> Enum.reduce(%{}, fn %{app: app, path: path}, acc ->
        Map.put(acc, "#{app}", "file:#{path}")
      end)

    res =
      package
      |> Map.put("dependencies", dependencies)
      |> Jason.encode!(pretty: true)

    File.write!(filepath, res)
  end

  defp create_app_js() do
    res =
      deps_assets("package.json")
      |> Enum.map(fn %{app: app} -> "import \"#{app}\"\n" end)
      |> Enum.join("")

    File.write!("assets/js/app.js", res)
  end

  def deps_assets(subpath) do
    deps =
      Deps.ordered_apps(@server_otp_app)
      |> Enum.reject(fn x -> x.app == @server_otp_app end)

    deps
    |> Enum.map(fn %{path: path} = config ->
      assets_path = Path.join([path, subpath])
      %{config | path: assets_path}
    end)
    |> Enum.filter(fn %{path: path} -> File.exists?(path) end)
  end
end
