defmodule Fablebook.GuardFixture.TokensToQuoted do
  def run(tokens, file, opts), do: :elixir.tokens_to_quoted(tokens, file, opts)
end
