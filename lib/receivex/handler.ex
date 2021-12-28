defmodule Receivex.Handler do
  @moduledoc """
  Behaviour for handling incoming webhook
  """
  @callback process(payload :: struct()) :: :ok | {:error, any()}
end

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
