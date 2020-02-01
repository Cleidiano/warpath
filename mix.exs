defmodule Warpath.MixProject do
  use Mix.Project
  @description "A implementation of Jsonpath expression for Elixir."
  @version "0.1.1"

  def project do
    [
      app: :warpath,
      name: "Warpath",
      description: @description,
      version: @version,
      elixir: "~> 1.6",
      package: package(),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      source_url: "https://github.com/cleidiano/warpath",
      docs: [main: "Warpath"]
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
      {:jason, "~> 1.1"},
      {:credo, "~> 1.2.1", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false}
    ]
  end

  defp package do
    %{
      maintainers: ["Cleidiano Oliviera"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/cleidiano/warpath"
      }
    }
  end
end
