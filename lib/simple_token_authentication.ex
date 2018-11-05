defmodule SimpleTokenAuthentication do
  import Plug.Conn

  @moduledoc """
  A plug that checks for presence of a simple token for authentication
  """
  @behaviour Plug
  def init(opts), do: opts

  def call(conn, _opts) do
    token = Application.get_env(:simple_token_authentication, :token)

    val = get_auth_header(conn)

    if token && String.trim(token) != "" && val == token do
      conn
    else
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(401, ~s({ "error": "Invalid shared key" }))
      |> halt
    end
  end

  defp get_auth_header(conn) do
    case get_req_header(conn, "authorization") do
      [val | _] -> val
      _ -> nil
    end
  end
end
