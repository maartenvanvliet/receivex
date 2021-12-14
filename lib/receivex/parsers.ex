defmodule Receivex.Parsers do
  def to_datetime(timestamp) when is_integer(timestamp) do
    case DateTime.from_unix(timestamp) do
      {:ok, timestamp} ->
        timestamp

      _ ->
        nil
    end
  end

  def to_datetime(timestamp) when is_float(timestamp) do
    case timestamp |> Kernel.trunc() |> DateTime.from_unix() do
      {:ok, timestamp} ->
        timestamp

      _ ->
        nil
    end
  end

  def to_datetime(""), do: nil

  def to_datetime(timestamp) when is_binary(timestamp) do
    if String.contains?(timestamp, ".") do
      timestamp
      |> String.to_float()
      |> to_datetime()
    else
      timestamp
      |> String.to_integer()
      |> to_datetime()
    end
  end

  def to_datetime(_timestamp), do: nil
end
