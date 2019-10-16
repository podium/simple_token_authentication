defmodule SimpleTokenAuthentication do
  import Plug.Conn

  @moduledoc """
  A plug that checks for presence of a simple token for authentication
  """
  @behaviour Plug

  def init(opts) do
    Keyword.get_lazy(opts, :token, &get_token_from_env/0)
  end

  def call(conn, nil) do
    send_401(conn, "Shared key not set")
  end

  def call(conn, token) do
    with {:ok, token} <- parse_token(token),
      [^token | _] <- get_req_header(conn, "authorization") do
        conn
    else
      {:error, error} -> send_401(conn, error)
      _ -> send_401(conn, "Invalid shared key")
    end
  end

  defp get_token_from_env do
    Application.get_env(:simple_token_authentication, :token)
  end

  defp send_401(conn, error) when is_binary(error) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(401, ~s({ "error": "#{error}" }))
    |> halt()
  end

  defp parse_token(token) when is_binary(token) do
    case String.trim(token) do
      "" -> {:error, "Shared key not set"}
      token -> {:ok, token}
    end
  end

  defp parse_token(token) when is_function(token, 0), do: token.() |> parse_token()

  defp parse_token({module, function_name}), do: module |> apply(function_name, []) |> parse_token()

  defp parse_token(_), do: {:error, "Shared key not set"}
end
