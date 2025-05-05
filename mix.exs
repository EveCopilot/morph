defmodule Morph.MixProject do
  use Mix.Project

  def project do
    [
      app: :morph,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:flow, "~> 1.2.4"},
      {:unzip, "~> 0.12.0"},
      {:yaml_elixir, "~> 2.11.0"}
    ]
  end
end
