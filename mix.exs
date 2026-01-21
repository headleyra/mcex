defmodule Mcex.MixProject do
  use Mix.Project

  def project do
    [
      app: :mcex,
      version: "0.97.0",
      elixir: "~> 1.19",
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
      {:elixir_uuid, "~> 1.2"},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},

      # Mc
      {:mc, git: "https://github.com/headleyra/mc.git"},

      # PostgreSQL
      {:postgrex, "~> 0.16"},

      # Redis
      {:redix, "~> 1.1"},
      {:castore, "~> 1.0"}
    ]
  end
end
