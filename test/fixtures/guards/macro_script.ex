defmodule Fablebook.GuardFixture.MacroScript do
  defmacro run(path) do
    quote(do: :file.script(unquote(path)))
  end
end
