# Receivex

[![Build Status](https://travis-ci.com/maartenvanvliet/receivex.svg?branch=master)](https://travis-ci.com/maartenvanvliet/receivex) [![Hex pm](http://img.shields.io/hexpm/v/receivex.svg?style=flat)](https://hex.pm/packages/receivex) [![Hex Docs](https://img.shields.io/badge/hex-docs-9768d1.svg)](https://hexdocs.pm/receivex) [![License](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
Package to deal with inbound email webhooks for several providers. Right now 
Mailgun and Mandrill are supported.


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `receivex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:receivex, "~> 0.1.0"}
  ]
end
```

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

    def process(%Receivex.Email{} = mail) do
      IO.inspect(mail)
    end
  end

```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/receivex](https://hexdocs.pm/receivex).

