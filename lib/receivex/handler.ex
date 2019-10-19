defmodule Receivex.Handler do
  @moduledoc """
  Behaviour for handling incoming email
  """
  @callback process(email :: Receivex.Email.t()) :: :ok | {:error, String.t()}
end
