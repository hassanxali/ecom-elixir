defmodule Ecom.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      EcomWeb.Telemetry,
      Ecom.Repo,
      {DNSCluster, query: Application.get_env(:ecom, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Ecom.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Ecom.Finch},
      # Start a worker by calling: Ecom.Worker.start_link(arg)
      # {Ecom.Worker, arg},
      # Start to serve requests, typically the last entry
      EcomWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Ecom.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    EcomWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
