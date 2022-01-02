defmodule ExcmsCore.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      ExcmsCore.Repo,
      # Start a worker by calling: ExcmsCore.Worker.start_link(arg)
      # {ExcmsCore.Worker, arg}
    ]

    children = if ExcmsCore.is_server_app_module(__MODULE__) do
      children ++ [
        # Start the PubSub system
        {Phoenix.PubSub, name: ExcmsCore.PubSub},
        # Start the Telemetry supervisor
        ExcmsCoreWeb.Telemetry,
        # Start the Endpoint (http/https)
        ExcmsCoreWeb.Endpoint
      ]
    else
      children
    end

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ExcmsCore.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ExcmsCoreWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
