defmodule SimpleTokenAuthentication.Mixfile do
  use Mix.Project

  @source_url "https://github.com/podium/simple_token_authentication"
  @version "0.6.0"

  def project do
    [
      app: :simple_token_authentication,
      version: @version,
      elixir: "~> 1.7",
      description: "A plug that checks for presence of a simple token for authentication",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      package: package(),
      test_coverage: [summary: [threshold: 70]]
    ]
  end

  def application do
    [applications: [:logger, :plug]]
  end

  defp deps do
    [
      {:credo, "~> 1.6", only: [:dev, :test]},
      {:ex_doc, "~> 0.28", only: :dev, runtime: false},
      {:plug, ">= 1.3.0"}
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: [
        "CHANGELOG.md",
        {:"README.md", title: "Readme"}
      ],
      source_url: @source_url,
      source_ref: "v#{@version}",
      homepage_url: @source_url
    ]
  end

  defp package do
    [
      name: :simple_token_authentication,
      files: ["lib", "mix.exs", "README*"],
      maintainers: ["Travis Elnicky", "Arthur Weagel"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/podium/simple_token_authentication",
        "Docs" => "https://hexdocs.pm/simple_token_authentication/#{@version}/",
        "Changelog" => "#{@source_url}/blob/master/CHANGELOG.md"
      }
    ]
  end
end
