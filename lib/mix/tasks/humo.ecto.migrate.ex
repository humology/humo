defmodule Mix.Tasks.Humo.Ecto.Migrate do
  use Mix.Task

  @impl true
  def run(_args) do
    Mix.shell().info("Running task humo.ecto.migrate")

    Humo.migrate()
  end
end
