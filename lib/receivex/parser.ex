defmodule Receivex.Parser do
  @moduledoc false

  def parse_timestamp(timestamp) when is_binary(timestamp), do: timestamp
  def parse_timestamp(timestamp) when is_integer(timestamp), do: Integer.to_string(timestamp)
  def parse_timestamp(timestamp) when is_float(timestamp), do: Float.to_string(timestamp)
  def parse_timestamp(_timestamp), do: nil

  @name_email_regex ~r/(?<name>.*)<(?<email>.*)>/
  @email_regex ~r/^[\w.!#$%&'*+\-\/=?\^`{|}~]+@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*$/i
  def parse_address(address) when is_binary(address) do
    name_and_email = Regex.named_captures(@name_email_regex, address)

    cond do
      is_map(name_and_email) and name_and_email["email"] =~ @email_regex ->
        {
          String.trim(name_and_email["name"]),
          String.trim(name_and_email["email"])
        }

      address =~ @email_regex ->
        {
          "",
          String.trim(address)
        }

      true ->
        nil
    end
  end

  def parse_address(_address), do: nil

  def parse_recipients(recipients) when is_binary(recipients) do
    recipients
    |> String.split(",")
    |> Enum.map(&parse_address(&1))
  end

  def parse_recipients(recipients) when is_list(recipients) do
    recipients
    |> Enum.map(fn [email, name] -> {name, email} end)
  end

  def parse_recipients(_recipients), do: nil
end
