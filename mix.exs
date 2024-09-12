defmodule Personal.MixProject do
  use Mix.Project

  def project do
    [
      app: :personal,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Personal.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:esbuild, "~> 0.5"},
      {:makeup_elixir, ">= 0.0.0"},
      {:makeup_erlang, ">= 0.0.0"},
      {:nimble_publisher, "~> 1.1.0"},
      {:phoenix, "~> 1.7"},
      {:phoenix_live_view, "~> 0.20"},
      {:tailwind, "~> 0.2"},
      {:tzdata, "~> 1.1"}
    ]
  end

  defp aliases() do
    [
      "site.build": ["build", "tailwind default --minify", "esbuild default --minify"]
    ]
  end
end
