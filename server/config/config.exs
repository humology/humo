# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

if Path.expand("#{Mix.env()}_deps.exs", __DIR__) |> File.exists?(), do:
  import_config "#{Mix.env()}_deps.exs"

config :excms_server,
  ecto_repos: [ExcmsCore.Repo]

# Configures the endpoint
config :excms_server, ExcmsServer.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "jgjMNNV0mMjjqQVqsndA68SDM01N9gp1LwwV/pYZqrxECS7tbpj1ar8O9wifgh8O",
  render_errors: [view: ExcmsServer.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: ExcmsServer.PubSub,
  live_view: [signing_salt: "YsbwsVkA"]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.12.18",
  default: [
    args: ~w(assets/js/app.js --bundle --target=es2016 --outdir=priv/static/assets),
    env: %{"NODE_PATH" => Path.expand("../../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
