defmodule Receivex.Adapter.Mailgun do
  @moduledoc false
  @behaviour Receivex.Adapter

  def handle_webhook(conn, handler, opts) do
    payload = conn.body_params

    api_key = Keyword.fetch!(opts, :api_key)

    case valid_webhook_request?(payload, api_key) do
      true ->
        payload
        |> normalize_params()
        |> handler.process()

        {:ok, conn}

      _ ->
        {:error, conn}
    end
  end

  defp valid_webhook_request?(
         %{
           "signature" =>
             signature = %{
               "timestamp" => timestamp,
               "token" => token,
               "signature" => expected_signature
             }
         },
         api_key
       )
       when is_map(signature) do
    valid_signature?(timestamp, token, expected_signature, api_key)
  end

  defp valid_webhook_request?(
         %{
           "timestamp" => timestamp,
           "token" => token,
           "signature" => expected_signature
         },
         api_key
       )
       when is_binary(timestamp) do
    valid_signature?(timestamp, token, expected_signature, api_key)
  end

  defp valid_webhook_request?(_, _), do: false

  defp valid_signature?(timestamp, token, expected_signature, api_key) do
    data = timestamp <> token

    :crypto.mac(:hmac, :sha256, api_key, data)
    |> Base.encode16(case: :lower)
    |> Plug.Crypto.secure_compare(expected_signature)
  end

  def normalize_params(
        email = %{
          "event-data" => %{
            "envelope" => %{
              "sender" => sender
            },
            "event" => event,
            "message" => %{
              "headers" => %{
                "from" => from,
                "message-id" => message_id,
                "subject" => subject,
                "to" => to
              }
            }
          }
        }
      ) do
    %Receivex.Email{
      message_id: message_id,
      event: event,
      sender: sender,
      to: recipients(to),
      from: from(from),
      subject: subject,
      raw_params: email
    }
  end

  def normalize_params(
        email = %{
          "event-data" => %{
            "event" => event,
            "message" => %{
              "headers" => %{
                "message-id" => message_id,
              }
            }
          }
        }
      ) do
    %Receivex.Email{
      message_id: message_id,
      event: event,
      raw_params: email
    }
  end

  def normalize_params(
        email = %{
          "Message-Id" => message_id,
          "From" => from,
          "Subject" => subject,
          "To" => to,
          "Sender" => sender,
          "body-html" => html,
          "body-plain" => text
        }
      ) do
    %Receivex.Email{
      message_id: message_id,
      sender: sender,
      to: recipients(to),
      from: from(from),
      subject: subject,
      html: html,
      text: text,
      raw_params: email
    }
  end

  defp from(from), do: parse_address(from)

  @regex ~r/(?<name>.*)<(?<email>.*)>/
  defp parse_address(address) do
    result = Regex.named_captures(@regex, address)

    {
      String.trim(result["name"]),
      String.trim(result["email"])
    }
  end

  defp recipients(recipients) do
    recipients
    |> String.split(",")
    |> Enum.map(&parse_address(&1))
  end
end
