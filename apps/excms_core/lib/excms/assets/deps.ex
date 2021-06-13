defmodule Mix.Tasks.Excms.Assets.Deps do
  use Mix.Task

  @impl true
  def run(_args) do
    copy_deps_assets()
  end

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

  Symlink unfortunately doesn't work, because another symlinks are used inside
  """
  defp copy_deps_assets() do
    Path.wildcard("../../deps/*/apps/*/assets") |> Enum.map(fn source ->
      dest = "#{source}/../../../assets"
      if File.exists?(dest), do: File.rm_rf!(dest)
      File.cp_r!(source, dest)

      System.cmd("npm", ["install", "--prefix", dest, "--production"])
    end)
  end
end
