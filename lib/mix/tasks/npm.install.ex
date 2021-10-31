defmodule Mix.Tasks.Excms.Npm.Install do
  use Mix.Task

  @impl true
  def run(_args) do
    Mix.Tasks.Excms.Assets.Gen.deps_assets("package.json")
    |> Enum.map(fn %{path: path} = config ->
      %{config | path: String.replace_suffix(path, "/package.json", "")}
    end)
    |> Enum.map(fn %{path: path} -> npm_install(path) end)

    npm_install("./")
  end

  defp npm_install(dest), do:
    System.cmd("npm", ["install", "--prefix", dest, "--production"])
end
