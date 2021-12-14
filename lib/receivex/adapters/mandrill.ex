defmodule Receivex.Adapter.Mandrill do
  @moduledoc false
  @behaviour Receivex.Adapter

  @mandrill_header "x-mandrill-signature"

  # Mandrill expects the webhook to respond to head req
  def handle_webhook(conn = %{method: "HEAD"}, _, _opts), do: {:ok, conn}

  def handle_webhook(conn, handler, opts) do
    url = Keyword.fetch!(opts, :url)
    secret = Keyword.fetch!(opts, :secret)

    case verify_header(conn, url, secret) do
      {:ok, conn} ->
        json_decoder = Keyword.get(opts, :json_decoder, Jason)

        conn.params
        |> build_emails(json_decoder)
        |> Enum.each(fn email ->
          handler.process(email)
        end)

        {:ok, conn}

      {:error, conn} ->
        {:error, conn}
    end
  end

  defp verify_header(conn, url, secret) do
    signature = build_signature(url, conn.body_params, secret)
    [expected] = Plug.Conn.get_req_header(conn, @mandrill_header)

    if Plug.Crypto.secure_compare(signature, expected) do
      {:ok, conn}
    else
      {:error, conn}
    end
  end

  defp build_signature(url, body, secret) do
    signed_data =
      body
      |> Map.to_list()
      |> Enum.sort_by(fn {key, _value} -> key end)
      |> Enum.reduce(url, fn {key, value}, acc ->
        acc <> key <> value
      end)

    signature =
      :crypto.mac(:hmac, :sha, secret, signed_data)
      |> Base.encode64()

    signature
  end

  defp build_emails(%{"mandrill_events" => events}, json_decoder) do
    {:ok, events} = json_decoder.decode(events)

    events
    |> Enum.map(fn email_payload -> normalize_params(email_payload) end)
    |> Enum.reject(&is_nil/1)
  end

  def normalize_params(email = %{"event" => event, "msg" => msg, "ts" => ts}) do
    %Receivex.Email{
      message_id: msg["headers"]["Message-Id"],
      event: event,
      from: {msg["from_name"], msg["from_email"]},
      subject: msg["subject"],
      to: recipients(msg),
      html: msg["html"],
      text: msg["text"],
      timestamp: Receivex.Parsers.to_datetime(ts),
      raw_params: email
    }
  end

  def normalize_params(_), do: nil

  defp recipients(%{"to" => recipients}) do
    recipients |> Enum.map(fn [email, name] -> {name, email} end)
  end
end
