defmodule Fablebook.GuardFixture.MacroQuote do
  defmacro run(quoted) do
    quote do
      Code.eval_quoted(unquote(quoted))
    end
  end
end
