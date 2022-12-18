defmodule Mix.Tasks.Humo.Assets.AllPlugins.Scss.Gen do
  use Mix.Task

  require Mix.Generator

  Mix.Generator.embed_template(:all_plugins_scss, """
  // Automatically generated
  // Imports plugins with assets/css/plugin.scss file
  <%= for path <- @paths do %>
  @import "<%= path %>";<% end %><%= if @app_has_plugin_scss do %>
  @import "./plugin.scss";<% end %>
  """)

  @impl true
  def run(_args) do
    Mix.shell().info("Running task humo.assets.all_plugins.scss.gen")

    res =
      all_plugins_scss_template(
        paths: plugin_scss_paths(),
        app_has_plugin_scss: File.exists?("assets/css/plugin.scss")
      )

    Mix.Generator.create_file("assets/css/all_plugins.scss", res, force: true)
  end

  defp plugin_scss_paths do
    server_app = Humo.server_app()

    for %{app: app, path: path} <- Humo.ordered_apps(),
        path = Path.join([path, "assets/css/plugin.scss"]),
        File.exists?(path) and app != server_app do
      Humo.Path.normalize(["../../", path])
    end
  end
end
