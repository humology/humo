import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :humo, Humo.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "humo_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :humo, HumoWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "J6Z7+jGyrH1Rp1K7XfvpOxpsKd8qCFp8QT7Fn6623t2Ys/XyHl60BnpD4M31rivQ",
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

config :humo, Humo.Authorizer, authorizer: Humo.Authorizer.Mock

config :humo, Humo.Warehouse,
  humo: [
    Humo.WarehouseTest.Page
  ]

