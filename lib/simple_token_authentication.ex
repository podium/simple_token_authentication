defmodule SimpleTokenAuthentication do
  import Plug.Conn

  @moduledoc """
  A plug that checks for presence of a simple token for authentication
  """
  @behaviour Plug
  def init(opts), do: opts

  def call(conn, _opts) do
    token = Application.get_env(:simple_token_authentication, :token)
    {_, val} = Enum.find conn.req_headers, {nil, nil}, fn
      ({key, _}) ->
        key == "authorization"
    end

    if token && val == token do
      conn
    else
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(401, "{ \"error\": \"Invalid shared key\" }")
      |> halt
    end
  end
end
