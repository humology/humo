defmodule Mix.Tasks.Humo.Assets.Copy do
  use Mix.Task

  @impl true
  def run(_args) do
    Mix.shell().info("Running task humo.assets.copy")

    assets_wildcard = "assets/static/**/*"

    for %{path: path} <- Humo.ordered_apps(),
        filepath <- Path.join(path, assets_wildcard) |> Path.wildcard(),
        into: %{} do
      static_assets_path =
        Path.join(path, "assets/static")
        |> String.replace_prefix("./", "")

      relative_filepath = Path.relative_to(filepath, static_assets_path)

      {relative_filepath, filepath}
    end
    |> Enum.map(fn {relative_filepath, filepath} ->
      if File.regular?(filepath) do
        destpath = Path.join("priv/static", relative_filepath)

        # TODO if file didn't change, don't copy
        Mix.Generator.copy_file(filepath, destpath, force: true)
      end
    end)
  end
end
