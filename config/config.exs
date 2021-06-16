# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of Mix.Config.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
use Mix.Config

excms_deps = Path.expand("../apps/excms_core/lib/excms_deps.ex", __DIR__)

if File.exists?(excms_deps) do
  Code.require_file(excms_deps)
  for config <- ExcmsDeps.configs(), do: import_config(config)
end

config :excms_server,
  ecto_repos: [ExcmsCore.Repo]

# Configures the endpoint
config :excms_server, ExcmsServer.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "gxYF7dh9lo82W101uPyQvvO7ZSi5Qmn2aJOpE4QVyR4NE7fZtiv+Q4Ts+dVAWsVs",
  render_errors: [view: ExcmsCoreWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: ExcmsCore.PubSub,
  live_view: [signing_salt: "UsNQ2Ujs"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
