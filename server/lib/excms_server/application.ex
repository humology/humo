defmodule ExcmsServer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the PubSub system
      {Phoenix.PubSub, name: ExcmsServer.PubSub},
      # Start the Telemetry supervisor
      ExcmsServer.Telemetry,
      # Start the Endpoint (http/https)
      ExcmsServer.Endpoint
      # Starts a worker by calling: ExcmsServer.Worker.start_link(arg)
      # {ExcmsServer.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ExcmsServer.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    ExcmsServer.Endpoint.config_change(changed, removed)
    :ok
  end
end
