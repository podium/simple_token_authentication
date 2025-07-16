defmodule SimpleTokenAuthenticationTest do
  use ExUnit.Case, async: false
  import Plug.Test
  import Plug.Conn
  import ExUnit.CaptureLog
  require Logger

  @opts SimpleTokenAuthentication.init([])

  defmacro with_token(token, do: expression) do
    quote do
      Application.put_env(:simple_token_authentication, :token, unquote(token))
      unquote(expression)
      Application.put_env(:simple_token_authentication, :token, nil)
    end
  end

  defmacro with_service_tokens(tokens, do: expression) do
    quote do
      Application.put_env(:simple_token_authentication, :service_tokens, unquote(tokens))
      unquote(expression)
      Application.put_env(:simple_token_authentication, :service_tokens, nil)
    end
  end

  defmacro with_other_realm_token(token, do: expression) do
    quote do
      Application.put_env(:simple_token_authentication, :another_realm, token: unquote(token))

      unquote(expression)
      Application.put_env(:simple_token_authentication, :another_realm, token: nil)
    end
  end

  setup do
    :persistent_term.erase(:simple_token_authentication_map)
    :persistent_term.erase(:simple_token_authentication_another_realm_map)

    :ok
  end

  describe "without a token" do
    test "returns a 401 status code" do
      with_token(nil) do
        # Create a test connection
        conn = conn(:get, "/foo")

        # Invoke the plug
        conn = SimpleTokenAuthentication.call(conn, @opts)

        # Assert the response and status
        assert conn.status == 401
      end
    end
  end

  test "handles the lack of an auth header" do
    with_token("fake_token") do
      conn =
        :get
        |> conn("/foo")
        |> SimpleTokenAuthentication.call(@opts)

      assert conn.status == 401
    end
  end

  describe "empty token" do
    test "returns a 401 status code" do
      with_token("") do
        # Create a test connection
        conn =
          :get
          |> conn("/foo")
          |> put_req_header("authorization", "")

        # Invoke the plug
        conn = SimpleTokenAuthentication.call(conn, @opts)

        # Assert the response and status
        assert conn.status == 401
        assert conn.assigns[:simple_token_auth_service] == nil
      end
    end
  end

  describe "with an invalid token" do
    test "returns a 401 status code" do
      with_token("fake_token") do
        # Create a test connection
        conn =
          :get
          |> conn("/foo")
          |> put_req_header("authorization", "wrong_token")

        # Invoke the plug
        conn = SimpleTokenAuthentication.call(conn, @opts)

        # Assert the response and status
        assert conn.status == 401
      end
    end
  end

  describe "with a valid token" do
    test "returns a 200 status code" do
      with_token("fake_token") do
        # Create a test connection
        conn =
          :get
          |> conn("/foo")
          |> put_req_header("authorization", "fake_token")

        # Invoke the plug
        conn = SimpleTokenAuthentication.call(conn, @opts)

        # Assert the response and status
        assert conn.status != 401
        assert conn.assigns[:simple_token_auth_service] == :global
      end
    end
  end

  describe "with multiple tokens" do
    test "returns a 200 status code if one of the tokens matches" do
      with_token(["bad_token", "fake_token"]) do
        # Create a test connection
        conn =
          :get
          |> conn("/foo")
          |> put_req_header("authorization", "fake_token")

        # Invoke the plug
        conn = SimpleTokenAuthentication.call(conn, @opts)

        # Assert the response and status
        assert conn.status != 401
        assert conn.assigns[:simple_token_auth_service] == :global
      end
    end

    test "returns a 401 status code if none of the tokens matches" do
      with_token(["bad_token", "other_bad_token"]) do
        # Create a test connection
        conn =
          :get
          |> conn("/foo")
          |> put_req_header("authorization", "fake_token")

        # Invoke the plug
        conn = SimpleTokenAuthentication.call(conn, @opts)

        # Assert the response and status
        assert conn.status == 401
        assert conn.assigns[:simple_token_auth_service] == nil
      end
    end
  end

  describe "with service tokens" do
    test "logs the service name" do
      with_service_tokens(test_service: "test_token") do
        # Create a test connection
        conn =
          :get
          |> conn("/foo")
          |> put_req_header("authorization", "test_token")

        # Invoke the plug
        conn = SimpleTokenAuthentication.call(conn, @opts)

        assert capture_log(fn ->
                 Logger.info("test log message")
               end) =~ "service_name=test_service"

        assert conn.assigns[:simple_token_auth_service] == :test_service
      end
    end

    test "returns a 401 status code if none of the service tokens matches" do
      with_service_tokens(bad: "bad_token", other: "other_bad_token") do
        # Create a test connection
        conn =
          :get
          |> conn("/foo")
          |> put_req_header("authorization", "fake_token")

        # Invoke the plug
        conn = SimpleTokenAuthentication.call(conn, @opts)

        # Assert the response and status
        assert conn.status == 401
        assert conn.assigns[:simple_token_auth_service] == nil
      end
    end
  end

  describe "another_realm_simple_token_authentication - without a token" do
    test "returns a 401 status code" do
      Application.put_env(:simple_token_authentication, :another_realm, token: nil)

      # Create a test connection
      conn = conn(:get, "/foo")

      # Invoke the plug with another realm
      conn =
        SimpleTokenAuthentication.call(conn,
          auth_realm: :another_realm
        )

      # Assert the response and status
      assert conn.status == 401

      Application.put_env(:simple_token_authentication, :another_realm, token: nil)
    end
  end

  describe "another_realm_simple_token_authentication - handles the lack of an auth header" do
    test "returns a 401 status code" do
      with_other_realm_token("fake_token") do
        conn =
          :get
          |> conn("/foo")
          |> SimpleTokenAuthentication.call(auth_realm: :another_realm)

        assert conn.status == 401
      end
    end
  end

  describe "another_realm_simple_token_authentication - empty token" do
    test "returns a 401 status code" do
      with_other_realm_token("") do
        # Create a test connection
        conn =
          :get
          |> conn("/foo")
          |> put_req_header("authorization", "")

        # Invoke the plug with another realm
        conn =
          SimpleTokenAuthentication.call(conn,
            auth_realm: :another_realm
          )

        # Assert the response and status
        assert conn.status == 401
        assert conn.assigns[:simple_token_auth_service] == nil
      end
    end
  end

  describe "another_realm_simple_token_authentication - with an invalid token" do
    test "returns a 401 status code" do
      with_other_realm_token("fake_token") do
        # Create a test connection
        conn =
          :get
          |> conn("/foo")
          |> put_req_header("authorization", "wrong_token")

        # Invoke the plug with another realm
        conn =
          SimpleTokenAuthentication.call(conn, auth_realm: :another_realm)

        # Assert the response and status
        assert conn.status == 401
      end
    end
  end

  describe "another_realm_simple_token_authentication - with a valid token" do
    test "returns a 200 status code" do
      with_other_realm_token("fake_token") do
        # Create a test connection
        conn =
          :get
          |> conn("/foo")
          |> put_req_header("authorization", "fake_token")

        # Invoke the plug with another realm
        conn =
          SimpleTokenAuthentication.call(conn, auth_realm: :another_realm)

        # Assert the response and status
        assert conn.status != 401
        assert conn.assigns[:simple_token_auth_service] == :global
      end
    end
  end

  describe "another_realm_simple_token_authentication - with multiple tokens" do
    test "returns a 200 status code if one of the tokens matches" do
      Application.put_env(:simple_token_authentication, :another_realm, token: nil)

      Application.put_env(:simple_token_authentication, :another_realm,
        token: [
          "bad_token",
          "fake_token"
        ]
      )

      # Create a test connection
      conn =
        :get
        |> conn("/foo")
        |> put_req_header("authorization", "fake_token")

      # Invoke the plug with another realm
      conn =
        SimpleTokenAuthentication.call(conn,
          auth_realm: :another_realm
        )

      # Assert the response and status
      assert conn.status != 401
      assert conn.assigns[:simple_token_auth_service] == :global

      Application.put_env(:simple_token_authentication, :another_realm, token: nil)
    end

    test "returns a 401 status code if none of the tokens matches" do
      Application.put_env(:simple_token_authentication, :another_realm,
        token: [
          "bad_token",
          "other_bad_token"
        ]
      )

      # Create a test connection
      conn =
        :get
        |> conn("/foo")
        |> put_req_header("authorization", "fake_token")

      # Invoke the plug with another realm
      conn =
        SimpleTokenAuthentication.call(conn,
          auth_realm: :another_realm
        )

      # Assert the response and status
      assert conn.status == 401
      assert conn.assigns[:simple_token_auth_service] == nil

      Application.put_env(:simple_token_authentication, :another_realm, token: nil)
    end
  end

  describe "another_realm - with service tokens" do
    test "logs the service name" do
      Application.put_env(:simple_token_authentication, :another_realm,
        service_tokens: [
          test_service: "test_token"
        ]
      )

      # Create a test connection
      conn =
        :get
        |> conn("/foo")
        |> put_req_header("authorization", "test_token")

      # Invoke the plug with another realm
      conn =
        SimpleTokenAuthentication.call(conn,
          auth_realm: :another_realm
        )

      assert capture_log(fn ->
               Logger.info("test log message")
             end) =~ "service_name=test_service"

      assert conn.assigns[:simple_token_auth_service] == :test_service

      Application.put_env(:simple_token_authentication, :another_realm, service_tokens: nil)
    end

    test "returns a 401 status code if none of the service tokens matches" do
      Application.put_env(:simple_token_authentication, :another_realm,
        service_tokens: [
          bad: "bad_token",
          other: "other_bad_token"
        ]
      )

      # Create a test connection
      conn =
        :get
        |> conn("/foo")
        |> put_req_header("authorization", "fake_token")

      # Invoke the plug with another realm
      conn =
        SimpleTokenAuthentication.call(conn,
          auth_realm: :another_realm,
          service_name: :another_realm_service
        )

      # Assert the response and status
      assert conn.status == 401
      assert conn.assigns[:simple_token_auth_service] == nil

      Application.put_env(:simple_token_authentication, :another_realm, service_tokens: nil)
    end
  end

  describe "cross-realm authentication failures" do
    test "another_realm token cannot authenticate against default realm" do
      with_other_realm_token("another_realm_token") do
        with_token("default_realm_token") do
          # Create a test connection with another_realm token
          conn =
            :get
            |> conn("/foo")
            |> put_req_header("authorization", "another_realm_token")

          # Invoke the plug with default realm (no auth_realm option)
          conn = SimpleTokenAuthentication.call(conn, @opts)

          # Assert the response and status - should fail
          assert conn.status == 401
          assert conn.assigns[:simple_token_auth_service] == nil
        end
      end
    end

    test "default realm token cannot authenticate against another_realm" do
      with_token("default_realm_token") do
        with_other_realm_token("another_realm_token") do
          # Create a test connection with default realm token
          conn =
            :get
            |> conn("/foo")
            |> put_req_header("authorization", "default_realm_token")

          # Invoke the plug with another realm
          conn = SimpleTokenAuthentication.call(conn, auth_realm: :another_realm)

          # Assert the response and status - should fail
          assert conn.status == 401
          assert conn.assigns[:simple_token_auth_service] == nil
        end
      end
    end
  end
end
