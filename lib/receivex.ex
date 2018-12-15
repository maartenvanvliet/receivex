defmodule Receivex do
  @moduledoc """
  Documentation for Receivex.

  Example configuration for Mandrill
  ```
  forward("_incoming", to: Receivex, init_opts: [
    adapter: Receivex.Adapter.Mandrill,
    adapter_opts: [
      secret: "i8PTcm8glMgsfaWf75bS1FQ",
      url: "http://example.com"
    ],
    handler: Example.Processor]
  )
  ```

  Example configuration for Mailgun
  ```
  forward("_incoming", to: Receivex, init_opts: [
    adapter: Receivex.Adapter.Mailgun,
    adapter_opts: [
      api_key: "some-key"
    ],
    handler: Example.Processor]
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

    {adapter, adapter_opts, handler}
  end

  @impl true
  def call(conn, opts) do
    {adapter, adapter_opts, handler} = opts

    case adapter.handle_webhook(conn, handler, adapter_opts) do
      {:ok, conn} ->
        conn |> send_resp(:ok, "ok") |> halt()

      {:error, conn, message} ->
        conn |> send_resp(:forbidden, "bad signature") |> halt()
    end
  end
end
