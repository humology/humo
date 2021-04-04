use Mix.Config

# Configure Mix tasks and generators
config :excms_core,
  ecto_repos: [ExcmsCore.Repo]

config :excms_core, ExcmsCore.Repo,
  migration_timestamps: [type: :utc_datetime_usec]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :excms_core, :plugins,
  excms_core: %{
    title: "Core",
    cms_links: [
      # Example
      # %{title: "Users", route: :cms_user_path, action: :index, args: []}
    ],
    account_links: [
      # Example
      # %{title: "Users", route: :cms_logout_path, action: :delete, args: []}
    ]
  }

config :excms_core, ExcmsCoreWeb.PluginsRouter,
  excms_core: %{
    routers: [],
    cms_routers: [ExcmsCoreWeb.Routers.Cms]
  }
