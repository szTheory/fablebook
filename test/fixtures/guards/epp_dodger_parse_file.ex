defmodule Fablebook.GuardFixture.EppDodgerParseFile do
  def run(path), do: :epp_dodger.parse_file(path)
end
