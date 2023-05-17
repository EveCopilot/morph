defmodule Morph.MixProject do
  use Mix.Project

  def project do
    [
      app: :morph,
      version: "0.1.0",
      elixir: "~> 1.14",
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
      {:unzip, "~> 0.8.0"},
      {:yaml_elixir, "~> 2.9.0"},
      {:jason, "~> 1.4"},
      {:ex_aws, "~> 2.4"},
      {:ex_aws_s3, "~> 2.4"},
      {:poison, "~> 5.0"},
      {:hackney, "~> 1.18"},
    ]
  end
end
