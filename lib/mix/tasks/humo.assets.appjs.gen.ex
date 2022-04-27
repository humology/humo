defmodule Mix.Tasks.Humo.Assets.Appjs.Gen do
  use Mix.Task

  @impl true
  def run(_args) do
    Mix.shell().info("Running task humo.assets.appjs.gen")

    res =
      deps_with_package_json()
      |> Enum.map(fn app -> "import \"#{app}\"\n" end)
      |> Enum.join("")

    res = ~s(#{res}import "./plugin"\n)

    Mix.Generator.create_file("assets/js/app.js", res, force: true)
  end

  defp deps_with_package_json() do
    server_app = Humo.server_app()

    for %{app: app, path: path} <- Humo.ordered_apps(),
        File.exists?(Path.join([path, "package.json"])) and app != server_app do
      app
    end
  end
end
