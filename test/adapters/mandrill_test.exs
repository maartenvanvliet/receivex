defmodule Receivex.Adapter.MandrillTest do
  use ExUnit.Case
  use Plug.Test

  defmodule TestProcessor do
    @behaviour Receivex.Handler

    def process(email) do
      send(self(), {:email, email})
    end
  end

  defp setup_webhook do
    params = "./test/fixtures/mandrill.json" |> File.read!() |> URI.encode_www_form()

    conn(:post, "/_incoming", "mandrill_events=" <> params)
    |> put_req_header("content-type", "application/x-www-form-urlencoded")
    |> put_req_header("x-mandrill-signature", "Isdz1IXVrMypOLqoVlY+5iqBeNc=")
  end

  test "processes valid webhook" do
    conn = setup_webhook()

    {:ok, _conn} =
      Receivex.Adapter.Mandrill.handle_webhook(conn, TestProcessor,
        url: "http://example.com/_incoming",
        secret: "secret"
      )

    assert_receive {:email, %Receivex.Email{}}
  end

  test "returns error for valid webhook" do
    conn = setup_webhook()

    {:error, _conn, "Bad signature"} =
      Receivex.Adapter.Mandrill.handle_webhook(conn, TestProcessor,
        url: "http://example.com/_incoming",
        secret: "incorrect secret"
      )

    refute_receive {:email, %Receivex.Email{}}
  end

  test "normalizes email" do
    [event1, _] = Jason.decode!(File.read!("./test/fixtures/mandrill.json"))

    assert %Receivex.Email{
             from: {nil, "example.sender@mandrillapp.com"},
             html:
               "<p>This is an example inbound message.</p><img src=\"http://mandrillapp.com/track/open.php?u=999&id=aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa&tags=_all,_sendexample.sender@mandrillapp.com\" height=\"1\" width=\"1\">\n",
             sender: nil,
             subject: "This is an example webhook message",
             text: "This is an example inbound message.\n",
             to: [{nil, "example@example.com"}]
           } == Receivex.Adapter.Mandrill.normalize_params(event1)
  end
end
