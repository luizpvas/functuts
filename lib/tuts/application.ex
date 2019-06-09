defmodule Tuts.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the endpoint when the application starts
      TutsWeb.Endpoint,

      {ConCache, [
        name: :cache,
        ttl_check_interval: :timer.seconds(10),
        global_ttl: :timer.minutes(5)]
      }
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Tuts.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    TutsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
