defmodule ReceivexTest do
  use ExUnit.Case
  use Plug.Test

  defmodule TestProcessor do
    @behaviour Receivex.Handler

    def process(email) do
      send(self(), {:email, email})
    end
  end

  defmodule TestAdapter do
    @behaviour Receivex.Adapter

    @impl true
    def handle_webhook(conn, handler, _opts) do
      case conn.body_params do
        %{"invalid" => "true"} ->
          {:error, conn, "Invalid"}

        _ ->
          email = normalize_params(conn.body_params)

          handler.process(email)
          {:ok, conn}
      end
    end

    @impl true
    def normalize_params(payload) do
      %Receivex.Email{
        from: {nil, payload["from"]},
        subject: nil,
        to: nil,
        html: nil,
        text: payload["subject"]
      }
    end
  end

  @opts Receivex.init(
          adapter: TestAdapter,
          adapter_opts: [],
          handler: TestProcessor
        )

  test "sends mail to processor" do
    conn =
      conn(:post, "/_incoming", "subject=Hello+World&from=test%40example.com")
      |> put_req_header("content-type", "application/x-www-form-urlencoded")

    conn = Plug.Parsers.call(conn, Plug.Parsers.init(parsers: [:urlencoded, :multipart]))
    conn = Receivex.call(conn, @opts)
    assert 200 == conn.status
    assert conn.halted

    assert_receive {:email,
                    %Receivex.Email{
                      from: {nil, "test@example.com"},
                      html: nil,
                      sender: nil,
                      subject: nil,
                      text: "Hello World",
                      to: nil
                    }}
  end

  test "returns error for invalid mail requests" do
    conn =
      conn(:post, "/_incoming", "invalid=true&subject=Hello+World&from=test%40example.com")
      |> put_req_header("content-type", "application/x-www-form-urlencoded")

    conn = Plug.Parsers.call(conn, Plug.Parsers.init(parsers: [:urlencoded, :multipart]))
    conn = Receivex.call(conn, @opts)

    assert 403 == conn.status
    assert conn.halted

    refute_receive {:email, _}
  end
end
