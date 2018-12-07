defmodule SimpleTokenAuthentication.Mixfile do
  use Mix.Project

  @version "0.3.0"

  def project do
    [
      app: :simple_token_authentication,
      version: @version,
      elixir: "~> 1.7",
      description: description(),
      package: package(),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :plug]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:plug, "~> 1.7"},
      {:credo, "~> 1.0", only: [:dev, :test]},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end

  defp description do
    """
    A plug that checks for presence of a simple token for authentication
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*"],
      maintainers: ["Travis Elnicky", "Arthur Weagel"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/SRVentures/simple_token_authentication",
        "Docs" => "https://hexdocs.pm/simple_token_authentication/#{@version}/"
      }
    ]
  end
end
