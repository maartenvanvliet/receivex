defmodule Receivex.Adapter do
  @moduledoc """
  Behaviour for handling webhooks
  """
  @callback handle_webhook(conn :: Plug.Conn.t(), handler :: Atom.t(), opts :: []) ::
              {:ok, conn :: Plug.Conn.t()}
              | {:ok, conn :: Plug.Conn.t(), map()}
              | {:error, conn :: Plug.Conn.t(), String.t()}
              | {:error, conn :: Plug.Conn.t(), String.t(), map()}

  @callback normalize_params(payload :: any()) :: struct() | nil
end
