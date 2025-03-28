defmodule OcppGateway.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      OcppGateway.ChargePointRegistry,
      {Plug.Cowboy,
       scheme: :http,
       plug: OcppGateway.Router,
       options: [port: application_port()]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: OcppGateway.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp application_port do
    Application.get_env(:ocpp_gateway, :port, 4000)
  end
end
