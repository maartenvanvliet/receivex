defmodule Receivex.Email do
  @moduledoc """
  Struct modeling incoming email
  """
  @type address :: {String.t(), String.t()}

  @type t :: %__MODULE__{
          sender: String.t(),
          to: [address],
          from: address,
          html: String.t(),
          text: String.t(),
          subject: String.t()
        }
  defstruct [:sender, :to, :from, :subject, :html, :text]
end
