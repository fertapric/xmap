defmodule XMap.Mixfile do
  use Mix.Project

  @version "0.2.1"

  def project do
    [
      app: :xmap,
      name: "XMap",
      version: @version,
      elixir: "~> 1.4",
      deps: deps(),
      package: package(),
      description: description(),
      docs: docs()
   ]
  end

  def application do
    [
      extra_applications: [:xmerl]
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.14", only: [:test, :docs], runtime: false},
      {:inch_ex, ">= 0.0.0", only: [:dev, :docs], runtime: false}
    ]
  end

  defp description do
    """
    XML to Map converter.
    """
  end

  defp package do
    [
      maintainers: ["Fernando Tapia Rico"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/fertapric/xmap"},
      files: ~w(mix.exs README.md lib)
    ]
  end

  defp docs do
    [
      source_ref: "v#{@version}",
      main: "XMap",
      canonical: "http://hexdocs.pm/xmap",
      source_url: "https://github.com/fertapric/xmap"
    ]
  end
end
