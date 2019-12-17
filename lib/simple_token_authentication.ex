defmodule SimpleTokenAuthentication do
  import Plug.Conn
  import Plug.Crypto, only: [secure_compare: 2]

  @moduledoc """
  A plug that checks for presence of a simple token for authentication
  """
  @behaviour Plug
  def init(opts), do: opts

  def call(conn, _opts) do
    val = get_auth_header(conn)

    token_matches? =
      :simple_token_authentication
      |> Application.get_env(:token)
      |> List.wrap()
      |> Enum.any?(&matches?(&1, val))

    if token_matches? do
      conn
    else
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(401, ~s({ "error": "Invalid shared key" }))
      |> halt()
    end
  end

  defp get_auth_header(conn) do
    case get_req_header(conn, "authorization") do
      [val | _] -> val
      _ -> ""
    end
  end

  defp matches?(token, value) when is_binary(token) and is_binary(value), do: String.trim(token) != "" && secure_compare(token, value)

  defp matches?(_, _), do: false

end
