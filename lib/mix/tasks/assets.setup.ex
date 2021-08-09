defmodule Mix.Tasks.Excms.Assets.Setup do
  use Mix.Task

  @switches [
    generate: :boolean
  ]

  @aliases [
    g: :generate,
  ]

  @default_opts [generate: false]

  @doc """
  Solves problem with package.json dependencies relative path
  from directory apps/app2/assets
  ../../../deps/app1/apps/app1/assets
  from directory deps/app2/apps/app2/assets
  ../../../../../deps/app1/apps/app1/assets - relative path is different

  Solution - put assets in root folder of dependency
  pwd = apps/app2/assets
  ../../../deps/app1/assets
  pwd = deps/app2/assets
  ../../../deps/app1/assets - relative path is equal

  Symlink unfortunately doesn't work, because npm puts another symlinks inside
  """
  @impl true
  def run(args) do
    {opts, _} = OptionParser.parse!(args, strict: @switches, aliases: @aliases)
    opts = Keyword.merge(@default_opts, opts)

    setup_deps_assets()
    if Keyword.fetch!(opts, :generate), do:
      Mix.Task.run("excms.assets.gen")
    Mix.Task.run("cmd", ["npm", "install", "--prefix", "assets"])
  end

  defp setup_deps_assets() do
    Path.wildcard("../../deps/*/apps/*/assets") |> Enum.map(fn source ->
      dest = "#{source}/../../../assets"
      npm_install(dest)
    end)
  end

  defp npm_install(dest), do: System.cmd("npm", ["install", "--prefix", dest, "--production"])
end
