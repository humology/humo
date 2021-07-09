import Config

config :excms_core, Excms.Deps,
  deps: [
    :ecto_sql,
    :gettext,
    :jason,
    :phoenix,
    :phoenix_ecto,
    :phoenix_html,
    :phoenix_pubsub,
    :plug_cowboy,
    :postgrex,
    :excms_core
  ]

config :excms_server, Excms.Deps,
  deps: [
    :ecto_sql,
    :gettext,
    :jason,
    :phoenix,
    :phoenix_ecto,
    :phoenix_html,
    :phoenix_pubsub,
    :plug_cowboy,
    :postgrex,
    :phoenix_live_dashboard,
    :telemetry_metrics,
    :telemetry_poller,
    :excms_core,
    :excms_server
  ]

if Path.expand("../apps/excms_core/config/config.exs", __DIR__) |> File.exists?(), do:
  import_config "../apps/excms_core/config/config.exs"
