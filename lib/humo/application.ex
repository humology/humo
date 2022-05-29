defmodule Humo.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children =
      [
        {
          true,
          [
            # Start the Ecto repository
            Humo.Repo,
            # Start a worker by calling: Humo.Worker.start_link(arg)
            # {Humo.Worker, arg}
          ]
        },
        {
          Humo.is_server_app_module(__MODULE__),
          [
            # Start the PubSub system
            {Phoenix.PubSub, name: Humo.PubSub},
            # Start the Telemetry supervisor
            HumoWeb.Telemetry,
            # Start the Endpoint (http/https)
            HumoWeb.Endpoint
          ]
        },
        {
          assets_watcher_enabled?(),
          [
            # Watches assets and copies from /deps and /assets folder to /priv
            Humo.AssetsWatcher
          ]
        }
      ]
      |> Keyword.get_values(true)
      |> List.flatten()

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Humo.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    HumoWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp assets_watcher_enabled?() do
    Application.fetch_env!(:humo, Humo)[:assets_watcher]
  end
end
