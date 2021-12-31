defmodule ExcmsCore.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      ExcmsCore.Repo,
      # Start a worker by calling: ExcmsCore.Worker.start_link(arg)
      # {ExcmsCore.Worker, arg}
    ]

    children = if ExcmsCore.server_app() == :excms_core do
      children ++ [
        # Start the PubSub system
        {Phoenix.PubSub, name: ExcmsCore.PubSub},
        # Start the Telemetry supervisor
        ExcmsCore.Telemetry,
        # Start the Endpoint (http/https)
        ExcmsCore.Endpoint
      ]
    else
      children
    end

    Supervisor.start_link(children, strategy: :one_for_one, name: ExcmsCore.Supervisor)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    ExcmsCore.Endpoint.config_change(changed, removed)
    :ok
  end
end
