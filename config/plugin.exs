# This file is responsible for configuring your plugin application
#
# This configuration can be partially overriden by plugin that has
# this application as dependency

# General application configuration
import Config

config :humo,
  ecto_repos: [Humo.Repo]

config :humo, Humo.Repo, migration_timestamps: [type: :utc_datetime_usec]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :humo, :plugins,
  humo: %{
    title: "Core",
    dashboard_links: [
      # Example
      # minimal %{title: "Users", route: :cms_user_path, action: :index}
      # %{title: "Users", route: :cms_user_path, action: :delete, method: "DELETE", opts: []}
    ],
    account_links: [
      # Example
      # minimal %{title: "Users", route: :cms_user_path, action: :index}
      # %{title: "Users", route: :cms_user_path, action: :delete, method: "DELETE", opts: []}
    ]
  }

config :humo, HumoWeb.PluginsRouter,
  humo: HumoWeb.PluginRouter

config :humo, HumoWeb.BrowserPlugs,
  humo: []

config :humo, Humo.Warehouse,
  humo: []

config :humo, Humo.Authorizer,
  authorizer: Humo.Authorizer.NoAccess

config :humo, HumoWeb.AuthorizationExtractor,
  extractor: HumoWeb.AuthorizationExtractor.NilAuthorization
