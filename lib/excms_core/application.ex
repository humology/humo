defmodule ExcmsCore.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      ExcmsCore.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: ExcmsCore.PubSub}
      # Start a worker by calling: ExcmsCore.Worker.start_link(arg)
      # {ExcmsCore.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: ExcmsCore.Supervisor)
  end
end
