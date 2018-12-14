defmodule Receivex.Adapter.MandrillTest do
  use ExUnit.Case

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
