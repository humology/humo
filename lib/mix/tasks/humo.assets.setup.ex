defmodule Mix.Tasks.Humo.Assets.Setup do
  use Mix.Task

  @impl true
  def run(_args) do
    Mix.shell().info("Running task humo.assets.setup")

    Mix.Task.run("humo.assets.app.js.gen")
    Mix.Task.run("humo.assets.all_plugins.scss.gen")
    Mix.Task.run("humo.assets.build.config.mjs.gen")
    Mix.Task.run("humo.assets.copy")
    Mix.Task.run("humo.npm.install")
  end
end
