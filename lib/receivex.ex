defmodule Receivex do
  @moduledoc """
  Documentation for Receivex.

  Place the Receivex plug before the Plug.Parsers. This is necessary for
  access to the raw body for checking the webhook signatures in some services

  Example configuration for Mandrill
  ```
  plug(Receivex,
    path: "/_incoming",
    adapter: Receivex.Adapter.Mandrill,
    adapter_opts: [
      secret: "i8PTcm8glMgsfaWf75bS1FQ",
      url: "http://example.com"
    ],
    handler: Example.Processor
  )
  ```

  Example configuration for Mailgun
  ```
  plug(Receivex,
    path: "/_incoming",
    adapter: Receivex.Adapter.Mailgun,
    adapter_opts: [
      api_key: "some-key"
    ],
    handler: Example.Processor
  )
  ```

  Example processor
  ```
    defmodule Example.Processor do
      @behaviour Receivex.Handler

      def handle(%Receivex.Email{} = mail) do
        IO.inspect(mail)
      end
    end

  ```
  """

  import Plug.Conn
  @behaviour Plug

  @impl true
  def init(opts) do
    handler = Keyword.fetch!(opts, :handler)

    adapter = Keyword.fetch!(opts, :adapter)
    adapter_opts = Keyword.fetch!(opts, :adapter_opts)
    path = Keyword.fetch!(opts, :path)

    {path, adapter, adapter_opts, handler}
  end

  @impl true
  def call(conn, opts) do
    {path, adapter, adapter_opts, handler} = opts

    case conn.request_path do
      ^path ->
        case adapter.handle_webhook(conn, handler, adapter_opts) do
          {:ok, conn} ->
            conn |> send_resp(:ok, "ok") |> halt()

          {:error, conn, message} ->
            conn |> send_resp(:forbidden, message) |> halt()
        end

      _ ->
        conn
    end
  end
end
