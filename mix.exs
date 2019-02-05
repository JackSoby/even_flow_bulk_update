defmodule EvenFlowBulkUpdate.MixProject do
  use Mix.Project

  def project do
    [
      app: :even_flow_bulk_update,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      applications: [:httpoison]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:csv, "~> 2.0.0"},
      {:httpoison, "~> 1.4"},
      {:poison, "~> 3.1"}
    ]
  end
end
