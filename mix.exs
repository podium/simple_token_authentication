defmodule SimpleTokenAuthentication.Mixfile do
  use Mix.Project

  @source_url "https://github.com/SRVentures/simple_token_authentication"
  @version "0.6.0"

  def project do
    [
      app: :simple_token_authentication,
      version: @version,
      elixir: "~> 1.7",
      description: description(),
      package: package(),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs()
    ]
  end

  def application do
    [applications: [:logger, :plug]]
  end

  defp deps do
    [
      {:credo, "~> 1.0", only: [:dev, :test]},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:plug, ">= 1.3.0"}
    ]
  end

  defp description do
    """
    """
  end

  defp package do
    [
      description: "A plug that checks for presence of a simple token "
        <> "for authentication",
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Travis Elnicky", "Arthur Weagel"],
      licenses: ["MIT"],
      links: %{
        "Changelog" => "https://hexdocs.pm/simple_token_authentication/changelog.html",
        "GitHub" => @source_url
      }
    ]
  end

  defp docs do
    [
      extras: [
        "CHANGELOG.md": [],
        "LICENSE.md": [title: "License"],
        "README.md": [title: "Overview"]
      ],
      main: "readme",
      source_url: @source_url,
      source_ref: "v#{@version}",
      formatters: ["html"],
      api_reference: false
    ]
  end
end
