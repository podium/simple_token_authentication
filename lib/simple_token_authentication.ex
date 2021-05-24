defmodule SimpleTokenAuthentication do
  import Plug.Conn
  require Logger

  @moduledoc """
  A plug that checks for presence of a simple token for authentication
  """
  @behaviour Plug
  def init(opts), do: opts

  def call(conn, _opts) do
    val = get_auth_header(conn)

    token_map =
      case :persistent_term.get(:simple_token_authentication_map, nil) do
        nil ->
          build_token_map()

        val ->
          val
      end

    if service_name = token_map[val] do
      Logger.metadata(service_name: service_name)
      assign(conn, :simple_token_auth_service, service_name)
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

  def build_token_map do
    global =
      :simple_token_authentication
      |> Application.get_env(:token)
      |> List.wrap()

    services =
      :simple_token_authentication
      |> Application.get_env(:service_tokens)
      |> List.wrap()

    token_map =
      for {service, tokens} <- [{:global, global} | services],
          token <- List.wrap(tokens),
          token != "",
          reduce: %{} do
        acc ->
          Map.put(acc, token, service)
      end

    :persistent_term.put(:simple_token_authentication_map, token_map)

    token_map
  end
end
