defmodule Mix.Tasks.Humo.Assets.AllPlugins.Js.Gen do
  use Mix.Task

  require Mix.Generator

  Mix.Generator.embed_template(:app_js, """
  // Automatically generated
  // Imports plugins with package.json file
  <%= for app <- @apps do %>
  import "<%= app %>"<% end %><%= if @app_has_plugin_js do %>
  import "./plugin"<% end %>
  """)

  @impl true
  def run(_args) do
    Mix.shell().info("Running task humo.assets.all_plugins.js.gen")

    res =
      app_js_template(
        apps: deps_with_package_json(),
        app_has_plugin_js: File.exists?("assets/js/plugin.js")
      )

    Mix.Generator.create_file("assets/js/all_plugins.js", res, force: true)
  end

  defp deps_with_package_json() do
    server_app = Humo.server_app()

    for %{app: app, path: path} <- Humo.ordered_apps(),
        File.exists?(Path.join([path, "package.json"])) and app != server_app do
      app
    end
  end
end
