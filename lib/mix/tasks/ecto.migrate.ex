defmodule Mix.Tasks.Humo.Ecto.Migrate do
  use Mix.Task

  @impl true
  def run(_args) do
    compile_deps()
    Humo.migrate()
  end

  defp compile_deps() do
    Mix.Task.run("app.start", ["--no-start"])
  end
end
