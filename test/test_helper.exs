ExUnit.start()

defmodule TestProcessor do
  @behaviour Receivex.Handler

  def process(email) do
    send(self(), {:email, email})
  end
end
