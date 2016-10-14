# SimpleTokenAuthentication

## Usage
### Phoenix Integration
  - Add plug to your pipeline like so:
  
  ```elixir
  pipeline :api do
    plug SimpleTokenAuthentication
  end
  ```

## Installation

  1. Add `simple_token_authentication` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:simple_token_authentication, "~> 0.1.0"}]
    end
    ```

  2. Ensure `simple_token_authentication` is started before your application:

    ```elixir
    def application do
      [applications: [:simple_token_authentication]]
    end
    ```

  3. Configure your token in `config.exs`:
    ```elixir
    config :simple_token_authentication, token: "your-token-here"
    ```

