defmodule Receivex.Adapter.Sendgrid do
  @moduledoc false
  @behaviour Receivex.Adapter

  def handle_webhook(conn, handler, _opts) do
    payload = conn.body_params

    payload
    |> normalize_params()
    |> handler.process()

    {:ok, conn}
  end

  def normalize_params(
        %{
          "from" => from,
          "to" => to,
          "subject" => subject
        } = params
      ) do
    html = Map.get(params, "html", "")
    # Sometimes Sendgrid doesn't send `text`.
    text = Map.get(params, "text", "")

    %Receivex.Email{
      from: parse_address(from),
      subject: subject,
      to: [parse_to(to)],
      html: html,
      text: text
    }
  end

  def normalize_params(_) do
    nil
  end

  @regex ~r/(?<name>.*)<(?<email>.*)>/
  defp parse_address(address) do
    result = Regex.named_captures(@regex, address)

    name = result["name"] || ""
    email = result["email"] || ""

    {
      String.trim(name),
      String.trim(email)
    }
  end

  # The `to` field in Sendgrid is pretty messy, these are all possible values:
  #   "Bob <bob@slickinbox.com>"
  #   "bob@slickinbox.com <bob@slickinbox.com>"
  #   "<bob@slickinbox.com>"
  #   "bob@slickinbox.com"
  defp parse_to(to) do
    case parse_address(to) do
      # "bob@slickinbox.com"
      {"", ""} ->
        {nil, to}

      # "<bob@slickinbox.com>"
      {"", email} ->
        {nil, email}

      # "Bob <bob@slickinbox.com>"
      result ->
        result
    end
  end
end
