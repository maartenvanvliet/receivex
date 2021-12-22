defmodule Receivex.Email do
  @moduledoc """
  Struct modeling incoming email
  """
  @type address :: {String.t(), String.t()}

  @type t :: %__MODULE__{
          message_id: String.t(),
          event: String.t(),
          sender: String.t() | nil,
          to: [address] | nil,
          from: address | nil,
          subject: String.t() | nil,
          html: String.t() | nil,
          text: String.t() | nil,
          timestamp: DateTime.t() | nil,
          raw_params: map()
        }
  defstruct [
    :message_id,
    :event,
    :sender,
    :to,
    :from,
    :subject,
    :html,
    :text,
    :timestamp,
    :raw_params
  ]
end
