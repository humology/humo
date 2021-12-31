# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

if Path.expand("#{Mix.env()}_deps.exs", __DIR__) |> File.exists?(),
  do: import_config("#{Mix.env()}_deps.exs")

# Configures the endpoint
config :excms_core, ExcmsCore.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "jgjMNNV0mMjjqQVqsndA68SDM01N9gp1LwwV/pYZqrxECS7tbpj1ar8O9wifgh8O",
  render_errors: [view: ExcmsCore.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: ExcmsCore.PubSub,
  live_view: [signing_salt: "YsbwsVkA"]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.0",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
