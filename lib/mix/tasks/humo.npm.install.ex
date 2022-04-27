defmodule Mix.Tasks.Humo.Npm.Install do
  use Mix.Task

  @impl true
  def run(_args) do
    Mix.shell().info("Running task humo.npm.install")

    for %{path: path} <- Humo.ordered_apps(),
        File.exists?(Path.join([path, "package.json"])) do
      System.cmd("npm", ["install", "--prefix", path, "--production"])
    end
  end
end
