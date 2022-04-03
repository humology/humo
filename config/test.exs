import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :excms_core, ExcmsCore.Repo,
  username: "postgres",
  password: "postgres",
  database: "excms_core_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :excms_core, ExcmsCoreWeb.Endpoint,
  http: [port: 4002],
  server: false

config :excms_core, ExcmsCore.Authorizer,
  authorizer: ExcmsCore.Authorizer.Mock

# Print only warnings and errors during test
config :logger, level: :warn

config :excms_core, ExcmsCore.Warehouse,
  excms_core: [
    ExcmsCore.WarehouseTest.Page
  ]
