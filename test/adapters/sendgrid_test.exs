defmodule Receivex.Adapter.SendgridTest do
  use ExUnit.Case
  use Plug.Test

  alias Receivex.Adapter

  defp setup_webhook do
    conn = conn(:post, "/_incoming", "raw_body")

    params = "./test/fixtures/sendgrid.json" |> File.read!() |> Jason.decode!()
    %{conn | body_params: params}
  end

  test "processes valid webhook" do
    conn = setup_webhook()

    {:ok, _conn} = Adapter.Sendgrid.handle_webhook(conn, TestProcessor, [])

    assert_receive {:email, %Receivex.Email{}}
  end

  test "normalizes email" do
    params = Jason.decode!(File.read!("./test/fixtures/sendgrid.json"))

    assert %Receivex.Email{
             from: {"Sender Name", "example@example.com"},
             html:
               "<div dir=\"ltr\">Here&#39;s an email with multiple attachments<div><br></div><div><img src=\"cid:ii_1562e2169c132d83\" alt=\"Inline image 1\" width=\"455\" height=\"544\"><br clear=\"all\"><div><br></div>-- <br><div class=\"gmail_signature\" data-smartmail=\"gmail_signature\"><div dir=\"ltr\"><img src=\"https: //sendgrid.com/brand/sg-logo-email.png\" width=\"96\" height=\"17\"><br><div><br></div></div></div>\n</div></div>",
             sender: nil,
             subject: "Different File Types",
             text: "Here's an email with multiple attachments",
             to: [{nil, "bob@slickinbox.com"}]
           } == Adapter.Sendgrid.normalize_params(params)
  end
end
