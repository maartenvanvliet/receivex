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
         %{"timestamp" => ts, "token" => token, "signature" => expected_signature},
         api_key
       ) do
    data = ts <> token

    signature = :crypto.hmac(:sha256, api_key, data) |> Base.encode16(case: :lower)

    Plug.Crypto.secure_compare(signature, expected_signature)
  end

  defp valid_webhook_request?(_, _), do: false

  def normalize_params(email) do
    %Receivex.Email{
      from: from(email),
      subject: email["subject"],
      to: recipients(email),
      sender: email["Sender"],
      html: email["body-html"],
      text: email["body-plain"]
    }
  end

  defp from(%{"From" => from}) do
    parse_address(from)
  end

  @regex ~r/(?<name>.*)<(?<email>.*)>/
  defp parse_address(address) do
    result = Regex.named_captures(@regex, address)

    {
      String.trim(result["name"]),
      String.trim(result["email"])
    }
  end

  defp recipients(%{"To" => recipients}) do
    recipients |> String.split(",") |> Enum.map(fn address -> parse_address(address) end)
  end
end
