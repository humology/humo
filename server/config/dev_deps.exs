import Config

config :excms_server, Excms.Deps,
  deps: [
    %{app: :excms_core, path: "../"},
    %{app: :excms_server, path: "./"}
  ]

if Path.expand("../../config/plugin.exs", __DIR__) |> File.exists?(), do:
  import_config "../../config/plugin.exs"
