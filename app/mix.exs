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
      {:cowboy, "~> 2.9"},
      {:plug, "~> 1.13"},
      {:plug_cowboy, "~> 2.5"},
      {:jason, "~> 1.3"},
      {:phoenix_pubsub, "~> 2.1"},
      {:websockex, "~> 0.4.3"},
      {:telemetry, "~> 1.0"}
    ]
  end
end
