defmodule Mix.Tasks.Humo.Npm.Install do
  use Mix.Task

  @impl true
  def run(_args) do
    Mix.shell().info("Running task humo.npm.install")

    otp_app = Humo.otp_app()

    for %{app: app, path: path} <- Humo.ordered_apps(),
        File.exists?(Path.join([path, "package.json"])) do
      args =
        if app == otp_app do
          ["install", "--prefix", path]
        else
          ["install", "--prefix", path, "--production"]
        end

      System.cmd("npm", args)
    end
  end
end
