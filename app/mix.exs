defmodule OcppGateway.MixProject do
  use Mix.Project

  def project do
    [
      app: :ocpp_gateway,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {OcppGateway.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:bandit, "~> 1.0"},
      {:gun, "~> 2.0"},
      {:mint_web_socket, "~> 1.0"},
      {:websock_adapter, "~> 0.5"}
    ]
  end
end
