defmodule SimpleTokenAuthenticationTest do
  use ExUnit.Case, async: false
  use Plug.Test

  @opts SimpleTokenAuthentication.init([])

  defmacro with_token(token, do: expression) do
    quote do
      Application.put_env(:simple_token_authentication, :token, unquote(token))
      unquote(expression)
      Application.put_env(:simple_token_authentication, :token, nil)
    end
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
      end
    end
  end
end
