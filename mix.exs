defmodule KafkaDispatcher.MixProject do
  use Mix.Project

  def project do
    [
      app: :kafka_dispatcher,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {KafkaDispatcher.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:brod, "~> 3.16"},
      {:poolboy, "~> 1.5"}
    ]
  end
end
