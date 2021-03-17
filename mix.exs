defmodule Receivex.MixProject do
  use Mix.Project

  @version "0.8.2"

  def project do
    [
      app: :receivex,
      version: @version,
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
      name: "Receivex",
      description: "Handle incoming mail webhooks for common mail providers",
      package: [
        maintainers: ["Maarten van Vliet"],
        licenses: ["MIT"],
        links: %{"GitHub" => "https://github.com/maartenvanvliet/receivex"},
        files: ~w(LICENSE README.md lib mix.exs)
      ],
      source_url: "https://github.com/maartenvanvliet/receivex",
      docs: [
        main: "readme",
        extras: ["README.md"]
      ]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:plug, "~> 1.11.1"},
      {:jason, ">= 0.0.0", only: [:dev, :test]},
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:credo, "~> 1.5.0", only: [:dev, :test], runtime: false}
    ]
  end
end
