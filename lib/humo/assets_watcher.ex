defmodule Humo.AssetsWatcher do
  use GenServer

  @timeout 500

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  @spec init(any) :: {:ok, %{assets_dirs: list, timer_id: nil}, {:continue, :init}}
  def init(_args) do
    state = %{assets_dirs: get_assets_dirs(), timer_id: nil}
    {:ok, state, {:continue, :init}}
  end

  def handle_continue(:init, state) do
    {:ok, _} =
      FileSystem.start_link(
        dirs: [Path.absname("")],
        name: :humo_assets_watcher
      )

    FileSystem.subscribe(:humo_assets_watcher)

    Mix.Tasks.Humo.Assets.Copy.run([])

    {:noreply, state}
  end

  def handle_info({:file_event, _pid, {path, _events}}, state) do
    if matches_any_assets_directory?(path, state.assets_dirs) do
      if state.timer_id, do: Process.cancel_timer(state.timer_id)

      timer_id = Process.send_after(self(), :assets_changed, @timeout)

      {:noreply, %{state | timer_id: timer_id}}
    else
      {:noreply, state}
    end
  end

  def handle_info({:file_event, _pid, :stop}, state) do
    {:noreply, state}
  end

  def handle_info(:assets_changed, state) do
    Mix.Tasks.Humo.Assets.Copy.run([])

    {:noreply, %{state | timer_id: nil}}
  end

  defp get_assets_dirs() do
    for %{path: path} <- Humo.ordered_apps() do
      Path.absname(Path.join(path, "assets/static"))
    end
  end

  defp matches_any_assets_directory?(path, assets_dirs) do
    Enum.any?(assets_dirs, fn assets_dir ->
      String.starts_with?(path, assets_dir)
    end)
  end
end
