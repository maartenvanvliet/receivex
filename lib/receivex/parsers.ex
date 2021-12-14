defmodule Receivex.Parsers do
  @moduledoc false

  def parse_timestamp(timestamp) when is_binary(timestamp), do: timestamp
  def parse_timestamp(timestamp) when is_integer(timestamp), do: Integer.to_string(timestamp)
  def parse_timestamp(timestamp) when is_float(timestamp), do: Float.to_string(timestamp)

  @regex ~r/(?<name>.*)<(?<email>.*)>/
  def parse_address(address) do
    %{"email" => email, "name" => name} = Regex.named_captures(@regex, address)

    {
      String.trim(name),
      String.trim(email)
    }
  end

  def parse_recipients(recipients) when is_binary(recipients) do
    recipients
    |> String.split(",")
    |> Enum.map(&parse_address(&1))
  end

  def parse_recipients(recipients) when is_list(recipients) do
    recipients
    |> Enum.map(fn [email, name] -> {name, email} end)
  end
end
