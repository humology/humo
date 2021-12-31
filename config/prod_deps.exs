import Config

config :excms_core, ExcmsCore,
  deps: [
    %{app: :excms_core, path: "./"}
  ],
  server_app: :excms_core

if Path.expand("./plugin.exs", __DIR__) |> File.exists?(), do:
  import_config "./plugin.exs"
