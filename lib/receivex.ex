defmodule Receivex do
  @moduledoc """
  Package that makes it easy to deal with inbound webhooks.


  ## Installation

  If [available in Hex](https://hex.pm/docs/publish), the package can be installed
  by adding `receivex` to your list of dependencies in `mix.exs`:

  ```elixir
  def deps do
  [
    {:receivex, "~> 0.8.2"}
  ]
  end
  ```


  Example configuration for Mandrill with the Plug router
  ```elixir
  forward("_incoming",
    to: Receivex,
    init_opts: [
      adapter: Receivex.Adapter.Mandrill,
      adapter_opts: [
        secret: "i8PTcm8glMgsfaWf75bS1FQ",
        url: "http://example.com"
      ],
      handler: Example.Processor
    ]
  )
  ```

  Example configuration for Mandrill with the Phoenix router
  ```elixir
  forward("_incoming", Receivex,
    adapter: Receivex.Adapter.Mandrill,
    adapter_opts: [
      secret: "i8PTcm8glMgsfaWf75bS1FQ",
      url: "http://example.com"
    ],
    handler: Example.Processor
  )
  ```

  Example configuration for Mailgun with the Plug router
  ```elixir
  forward("_incoming",
    to: Receivex,
    init_opts: [
      adapter: Receivex.Adapter.Mailgun,
      adapter_opts: [
        api_key: "some-key"
      ],
      handler: Example.Processor
    ]
  )
  ```

  Example configuration for custom adapter
  ```elixir
  forward("_incoming", Receivex,
    adapter: Your.Custom.Adapter,
    adapter_opts: [some_option: "some-option"],
    handler: Your.Processor
  )
  ```

  Example processor
  ```elixir
  defmodule Example.Processor do
    @behaviour Receivex.Handler

    def process(%Receivex.Email{} = mail) do
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

      {:ok, conn, resp} ->
        conn |> send_resp(:ok, Jason.encode!(resp)) |> halt()

      {:error, conn} ->
        conn |> send_resp(:forbidden, "bad signature") |> halt()

      {:error, conn, error_resp} ->
        conn |> send_resp(error_resp.code, Jason.encode!(error_resp.body)) |> halt()
    end
  end
end
