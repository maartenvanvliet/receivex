defmodule Receivex.Email do
  @moduledoc """
  Struct modeling incoming email
  """
  @type address :: {String.t(), String.t()}

  @type t :: %__MODULE__{
          message_id: String.t(),
          event: String.t(),
          sender: String.t(),
          to: [address],
          from: address,
          subject: String.t(),
          html: String.t(),
          text: String.t(),
          timestamp: DateTime.t(),
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
