defmodule Receivex.Handler do
  @callback process(email :: Receivex.Email.t()) :: :ok | {:error, String.t()}
end
