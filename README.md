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
    {:receivex, "~> 0.8.2"}
  ]
end
```

Example configuration for Mandrill with the Plug router

```elixir
forward("_incoming", to: Receivex, init_opts: [
  adapter: Receivex.Adapter.Mandrill,
  adapter_opts: [
    secret: "i8PTcm8glMgsfaWf75bS1FQ",
    url: "http://example.com"
  ],
  handler: Example.Processor]
)
```

Example configuration for Mandrill with the Phoenix router

```elixir
forward("_incoming", Receivex, [
  adapter: Receivex.Adapter.Mandrill,
  adapter_opts: [
    secret: "i8PTcm8glMgsfaWf75bS1FQ",
    url: "http://example.com"
  ],
  handler: Example.Processor]
)
```

Example configuration for Mailgun with the Plug router

```elixir
forward("_incoming", to: Receivex, init_opts: [
  adapter: Receivex.Adapter.Mailgun,
  adapter_opts: [
    api_key: "some-key"
  ],
  handler: Example.Processor]
)
```

Example configuration for Sendgrid with the Phoenix router

```elixir
forward("_incoming", Receivex, [
  adapter: Receivex.Adapter.Sendgrid,
  handler: Example.Processor]
)
```

### Note

Sendgrid does not always send the email in UTF-8, but Plug.Parser's default behaviour is to validate everything is in UTF-8. This means that out of the box, some of your emails that are not UTF-8 encoded will fail to reach your app.

The workaround is to tweak the `validate_utf8` option of `Plug.Parsers`. Here's an example how you can do it:

```elixir
# endpoint.ex
plug(:parse_body)

@normal_opts Plug.Parsers.init(
                 parsers: [:urlencoded, :multipart, :json],
                 pass: ["*/*"],
                 json_decoder: Phoenix.json_library()
               )

@webhook_opts Plug.Parsers.init(
                parsers: [:urlencoded, {:multipart, length: 20_000_000}, :json],
                pass: ["*/*"],
                json_decoder: Phoenix.json_library(),
                validate_utf8: false # this is the line you need
              )

defp parse_body(%{path_info: ["_incoming" | _]} = conn, _) do
  Plug.Parsers.call(conn, @webhook_opts)
end

defp parse_body(conn, _) do
  Plug.Parsers.call(conn, @normal_opts)
end
```

With this set-up, we keep the default `Plug.Parsers` behaviour unless the path is `_incoming`, in which case we don't validate UTF-8.

References:

- [Issue on Plug](https://github.com/elixir-plug/plug/issues/860)
- [Sendgrid Doc](https://sendgrid.com/docs/for-developers/parsing-email/inbound-email/#character-sets-and-header-decoding)

Example processor

```elixir
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
