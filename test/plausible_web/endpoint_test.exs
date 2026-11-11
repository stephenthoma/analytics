defmodule PlausibleWeb.EndpointTest do
  use ExUnit.Case, async: false
  use Plausible

  on_ee do
    describe "runtime_session_opts/0" do
      setup do
        original = Application.get_env(:plausible, :environment)
        on_exit(fn -> Application.put_env(:plausible, :environment, original) end)
      end

      test "pins the session cookie to the endpoint host outside development" do
        Application.put_env(:plausible, :environment, "prod")

        assert Keyword.fetch!(PlausibleWeb.Endpoint.runtime_session_opts(), :domain) ==
                 PlausibleWeb.Endpoint.host()
      end

      test "leaves the session cookie host-only in development" do
        Application.put_env(:plausible, :environment, "dev")

        refute Keyword.has_key?(PlausibleWeb.Endpoint.runtime_session_opts(), :domain)
      end
    end
  end

  describe "websocket_origin_allowed?/1" do
    setup do
      original = Application.get_env(:plausible, :environment)
      on_exit(fn -> Application.put_env(:plausible, :environment, original) end)
    end

    test "only allows the endpoint host outside development" do
      Application.put_env(:plausible, :environment, "prod")
      host = PlausibleWeb.Endpoint.host()

      assert PlausibleWeb.Endpoint.websocket_origin_allowed?(URI.parse("https://#{host}"))
      refute PlausibleWeb.Endpoint.websocket_origin_allowed?(URI.parse("https://evil.example"))
    end

    test "allows any origin in development" do
      Application.put_env(:plausible, :environment, "dev")

      assert PlausibleWeb.Endpoint.websocket_origin_allowed?(URI.parse("https://preview.example"))
    end
  end
end
