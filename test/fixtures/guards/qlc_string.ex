defmodule Fablebook.GuardFixture.QlcString do
  def run(query), do: :qlc.string_to_handle(query)
end
