defmodule Mix.Tasks.Humo.Assets.Build.Config.Mjs.Gen do
  use Mix.Task

  require Mix.Generator

  Mix.Generator.embed_template(:build_config_js, """
  // Automatically generated

  const sassLoadPaths = [<%= if @sass_load_paths != [] do %>
      '<%= Enum.join(@sass_load_paths, "',\n    '") %>'
  <% end %>]

  const nodePaths = [<%= if @node_paths != [] do %>
      '<%= Enum.join(@node_paths, "',\n    '") %>'
  <% end %>]

  export { sassLoadPaths, nodePaths }
  """)

  @impl true
  def run(_args) do
    Mix.shell().info("Running task humo.assets.build.config.mjs.gen")

    res = build_config_js_template(sass_load_paths: sass_load_paths(), node_paths: node_paths())

    Mix.Generator.create_file("assets/build.config.mjs", res, force: true)
  end

  defp sass_load_paths() do
    for %{path: path} <- Humo.ordered_apps() do
      Humo.Path.normalize(["../", path, "node_modules"])
    end
  end

  defp node_paths() do
    for %{path: path} <- Humo.ordered_apps() do
      Humo.Path.normalize(["../", path, "../"])
    end
    |> Enum.concat(["../deps"])
    |> Enum.uniq()
  end
end
