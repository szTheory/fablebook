defmodule Fablebook.GuardFixture.InternalEval do
  def run(source) do
    Process.put(:elixir_parser_warning_file, "nofile")
    Process.put(:elixir_parser_columns, false)
    Process.put(:elixir_token_metadata, false)
    Process.put(:elixir_literal_encoder, false)

    {:ok, _line, _column, _warnings, tokens, terminators} =
      :elixir_tokenizer.tokenize(String.to_charlist(source), 1, 1, [])

    {:ok, body} = :elixir_parser.parse(Enum.reverse(tokens, terminators))
    block = quote do: def(run, do: unquote(body))
    env = :elixir.env_for_eval([])
    :elixir_module.compile([], Fablebook.GuardFixture.Payload, block, [], false, env)
    apply(Fablebook.GuardFixture.Payload, :run, [])
  end
end
