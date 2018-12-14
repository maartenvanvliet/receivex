defmodule Receivex.Adapter do
  @callback handle_webhook(conn :: Plug.Conn.t(), handler :: Atom.t(), opts :: []) ::
              {:ok, conn :: Plug.Conn.t()} | {:error, conn :: Plug.Conn.t(), String.t()}

  @callback parse_request(conn :: Plug.Conn.t()) :: conn :: Plug.Conn.t()

  @callback normalize_params(email :: any) :: Receivex.Email.t() | nil
end
