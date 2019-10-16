# SimpleTokenAuthentication

## Usage
### Phoenix Integration
  - Inside `web/router.ex` file, add plug to your pipeline like so:
  
  ```elixir
  defmodule MyApp.Router
    use Phoenix.Router
    
    pipeline :api do
      plug SimpleTokenAuthentication, token: Application.get_env(:my_app, :my_simple_token)
    end
    
    scope "/", MyApp do
      pipe_through :api
      get "/hello", HelloController, :hello
    end
  end
  ```
  
It is recommended to set the token in your application config, rather than hard
coding it here, under your own application's namespace. For backwards compatibility,
you can also leave off the options and set the token in your config like so:
```elixir
  config :simple_token_authentication, token: "your-token-here"
```
However this only allows you to use simple token auth for a single token, so
it is mainly there for backwards compatibility.

## Installation

  1. Add `simple_token_authentication` to your list of dependencies in `mix.exs`:

  ```elixir
  def deps do
    [{:simple_token_authentication, "~> 1.0.0"}]
  end
  ```
