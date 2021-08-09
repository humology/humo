defmodule Mix.Tasks.Excms.Assets.Gen do
  use Mix.Task

  @server_otp_app :excms_server

  @impl true
  def run(_args) do
    create_copy_static_assets()
    update_package_json()
    create_app_js()
  end

  defp create_copy_static_assets() do
    dirs =
      deps_assets("/static")
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

    filepath = "../../apps/#{@server_otp_app}/assets/copy-static-assets.json"

    File.write!(filepath, json_config)
  end

  defp update_package_json() do
    assets =
      deps_assets("/package.json")
      |> Enum.map(fn {app, path} ->
        {app, String.replace_suffix(path, "/package.json", "")}
      end)

    filepath = "../../apps/#{@server_otp_app}/assets/package.json"

    package =
      File.read!(filepath)
      |> Jason.decode!()

    dependencies =
      assets
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
    assets =
      deps_assets("/package.json")
      |> Enum.map(fn {app, path} ->
        {app, String.replace_suffix(path, "/package.json", "")}
      end)

    filepath = "../../apps/#{@server_otp_app}/assets/js/app.js"

    res =
      assets
      |> Enum.map(fn {app, _} -> "import \"#{app}\"\n" end)
      |> Enum.join("")

    File.write!(filepath, res)
  end

  def deps_assets(subpath) do
    deps = Excms.Deps.ordered_apps(@server_otp_app) -- [@server_otp_app]

    deps
    |> Enum.map(fn app ->
      # deps assets must be copied to root
      path =
        [
          "deps/#{app}/assets#{subpath}",
          "apps/#{app}/assets#{subpath}"
        ]
        |> Enum.find(fn x -> File.exists?("../../"<>x) end)
      {app, path}
    end)
    |> Enum.reject(fn {_, path} -> is_nil(path) end)
    |> Enum.map(fn {app, path} -> {app, "../../../#{path}"} end)
  end
end
