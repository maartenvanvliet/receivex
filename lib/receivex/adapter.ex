defmodule Receivex.Adapter do
  @moduledoc """
  Behaviour for handling webhooks for different providers
  """
  @callback handle_webhook(conn :: Plug.Conn.t(), handler :: Atom.t(), opts :: []) ::
              {:ok, conn :: Plug.Conn.t()} | {:error, conn :: Plug.Conn.t(), String.t()}

  @callback normalize_params(email :: any) :: Receivex.Email.t() | nil
end
