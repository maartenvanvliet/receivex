defmodule Receivex.Adapter.MandrillTest do
  use ExUnit.Case
  use Plug.Test

  alias Receivex.Adapter

  defp setup_webhook do
    params = "./test/fixtures/mandrill.json" |> File.read!() |> URI.encode_www_form()

    conn(:post, "/_incoming", "mandrill_events=" <> params)
    |> put_req_header("content-type", "application/x-www-form-urlencoded")
    |> put_req_header("x-mandrill-signature", "Isdz1IXVrMypOLqoVlY+5iqBeNc=")
    |> Plug.Parsers.call(Plug.Parsers.init(parsers: [:urlencoded, :multipart]))
  end

  test "returns for head req" do
    conn = setup_webhook()

    {:ok, _conn} =
      Adapter.Mandrill.handle_webhook(%{conn | method: "HEAD"}, TestProcessor,
        url: "http://example.com/_incoming",
        secret: "secret"
      )

    refute_receive {:email, %Receivex.Email{}}
  end

  test "processes valid webhook" do
    conn = setup_webhook()

    {:ok, _conn} =
      Adapter.Mandrill.handle_webhook(conn, TestProcessor,
        url: "http://example.com/_incoming",
        secret: "secret"
      )

    assert_receive {:email, %Receivex.Email{}}
  end

  test "returns error for valid webhook" do
    conn = setup_webhook()

    {:error, _conn} =
      Adapter.Mandrill.handle_webhook(conn, TestProcessor,
        url: "http://example.com/_incoming",
        secret: "incorrect secret"
      )

    refute_receive {:email, %Receivex.Email{}}
  end

  test "normalizes email" do
    [event1, _] = Jason.decode!(File.read!("./test/fixtures/mandrill.json"))

    assert %Receivex.Email{
             message_id: "<999.20130510192820.aaaaaaaaaaaaaa.aaaaaaaa@mail115.us4.mandrillapp.com>",
             event: "inbound",
             from: {nil, "example.sender@mandrillapp.com"},
             html:
               "<p>This is an example inbound message.</p><img src=\"http://mandrillapp.com/track/open.php?u=999&id=aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa&tags=_all,_sendexample.sender@mandrillapp.com\" height=\"1\" width=\"1\">\n",
             sender: nil,
             subject: "This is an example webhook message",
             text: "This is an example inbound message.\n",
             to: [{nil, "example@example.com"}],
             raw_params: event1
           } == Adapter.Mandrill.normalize_params(event1)
  end
end
