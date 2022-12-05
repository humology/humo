defmodule Mix.Tasks.Humo.Assets.Watch do
  use Mix.Task

  @impl true
  def run(_args) do
    Mix.shell().info("Running task humo.assets.watch")

    {:ok, _watcher} = Humo.AssetsWatcher.start_link([])
    Process.sleep(:infinity)
  end
end
