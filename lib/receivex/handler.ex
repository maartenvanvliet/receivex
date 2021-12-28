defmodule Receivex.Handler do
  @moduledoc """
  Behaviour for handling incoming webhook
  """
  @callback process(payload :: struct()) :: :ok | {:error, any()}
end
