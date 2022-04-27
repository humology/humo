defmodule Mix.Tasks.Humo.Assets.Setup do
  use Mix.Task

  @impl true
  def run(_args) do
    Mix.shell().info("Running task humo.assets.setup")

    Mix.Task.run("humo.assets.appjs.gen")
    Mix.Task.run("humo.assets.copy")
    Mix.Task.run("humo.npm.install")
  end
end
