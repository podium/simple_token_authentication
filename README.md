# SimpleTokenAuthentication

## Usage
### Phoenix Integration
  - Inside `web/router.ex` file, add plug to your pipeline like so:
  
  ```elixir
  defmodule MyApp.Router
    use Phoenix.Router
    
    pipeline :api do
      plug SimpleTokenAuthentication
    end
    
    scope "/", MyApp do
      pipe_through :api
      get "/hello", HelloController, :hello
    end
  end
  ```

## Installation

  1. Add `simple_token_authentication` to your list of dependencies in `mix.exs`:

  ```elixir
  def deps do
    [{:simple_token_authentication, "~> 0.6.0"}]
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
  config :simple_token_authentication,
    token: "your-token-here",
    service_tokens: [
      service_a: "service-a-token",
      service_b: "service-b-token"
    ]
  ```

  4. Configure your connecting application to pass a token in the `authorization` header, e.g.:
  ```elixir
  put_header("authorization", "your-token-here")
  ```
  
## Notes
  - token value can be a comma-separated list of tokens
  - specifying `service_tokens` is optional
  - auth will succeed if token exists in *either* list (`token` or `service_tokens`)
  - Use of a service token will add "service_name" to `Logging.metadata`
  - Service can be identified in the conn.assigns[:simple_token_auth_service]. Will be the name of the service or :global when matching the token key
