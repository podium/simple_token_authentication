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

    case secure_lookup(token_map, val) do
      {:ok, service_name} ->
        Logger.metadata(service_name: service_name)
        assign(conn, :simple_token_auth_service, service_name)

      :error ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(401, ~s({ "error": "Invalid shared key" }))
        |> halt()
    end
  end

  defp secure_lookup(token_map, val) do
    Enum.find_value(token_map, :error, fn {token, service_name} ->
      if Plug.Crypto.secure_compare(token, val), do: {:ok, service_name}
    end)
  end

  defp get_auth_header(conn) do
    case get_req_header(conn, "authorization") do
      [val | _] -> val
      _ -> ""
    end
  end

  defp build_token_map(nil) do
    global = token()
    services = service_tokens(nil)

    token_map =
      for {service, tokens} <- [{:global, global} | services],
          token <- List.wrap(tokens),
          token != "",
          reduce: %{} do
        acc ->
          Map.put(acc, token, service)
      end

    :persistent_term.put(store(nil), token_map)

    token_map
  end

  defp build_token_map(realm) do
    services = service_tokens(realm)

    token_map =
      for {service, tokens} <- services,
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

  defp token do
    :simple_token_authentication
    |> Application.get_env(:token)
    |> List.wrap()
  end

  defp store(nil) do
    :default
  end

  defp store(realm) do
    realm
  end
end
