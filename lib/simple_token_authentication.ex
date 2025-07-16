defmodule SimpleTokenAuthentication do
  @moduledoc """
  A plug that checks for presence of a simple token for authentication
  """
  @behaviour Plug

  import Plug.Conn
  require Logger

  def init(opts), do: opts

  def call(conn, opts) do
    realm = Keyword.get(opts, :auth_realm)
    val = get_auth_header(conn)

    token_map =
      case :persistent_term.get(store(realm), nil) do
        nil ->
          build_token_map(realm)

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

  def build_token_map(realm) do
    global = token(realm)
    services = service_tokens(realm)

    token_map =
      for {service, tokens} <- [{:global, global} | services],
          token <- List.wrap(tokens),
          token != "",
          reduce: %{} do
        acc ->
          Map.put(acc, token, service)
      end

    :persistent_term.put(store(realm), token_map)

    token_map
  end

  defp service_tokens(nil) do
    :simple_token_authentication
    |> Application.get_env(:service_tokens)
    |> List.wrap()
  end

  defp service_tokens(realm) do
    :simple_token_authentication
    |> Application.get_env(realm)
    |> Keyword.get(:service_tokens)
    |> List.wrap()
  end

  defp token(nil) do
    :simple_token_authentication
    |> Application.get_env(:token)
    |> List.wrap()
  end

  defp token(realm) do
    :simple_token_authentication
    |> Application.get_env(realm)
    |> Keyword.get(:token)
    |> List.wrap()
  end

  defp store(nil) do
    :simple_token_authentication_map
  end

  defp store(realm) do
    String.to_atom("simple_token_authentication_" <> Atom.to_string(realm) <> "_map")
  end
end
