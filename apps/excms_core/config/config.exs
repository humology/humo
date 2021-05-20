use Mix.Config

# Configure Mix tasks and generators
config :excms_core,
  ecto_repos: [ExcmsCore.Repo]

config :excms_core, ExcmsCore.Repo, migration_timestamps: [type: :utc_datetime_usec]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :excms_core, :plugins,
  excms_core: %{
    title: "Core",
    cms_links: [
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

config :excms_core, ExcmsCoreWeb.PluginsRouter,
  excms_core: %{
    routers: [],
    cms_routers: [ExcmsCoreWeb.Routers.Cms]
  }

config :excms_core, ExcmsCoreWeb.BrowserPlugs,
  [{ExcmsCoreWeb.LocalePlug, true}, {ExcmsCoreWeb.SetAdministratorPlug, true}]

config :excms_core, ExcmsCore.Warehouse, excms_core: [ExcmsCore.GlobalAccess]
