defmodule Mcex.MixProject do
  use Mix.Project

  def project do
    [
      app: :mcex,
      version: "0.7.1",
      elixir: "~> 1.9",
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
      {:httpoison, "~> 1.6"},
      {:jason, "~> 1.2"},
      {:elixir_uuid, "~> 1.2"},
      {:tesla, "~> 1.3"},

      # Mc
      {:mc, git: "git://github.com/headleyra/mc.git"},

      # Redis
      {:redix, "~> 1.0.0"},
      {:castore, "~> 0.1.9"}

      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
