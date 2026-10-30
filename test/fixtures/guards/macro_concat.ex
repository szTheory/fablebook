defmodule Fablebook.GuardFixture.MacroConcat do
  defmacro run(x) do
    quote(do: Module.concat(unquote(x)))
  end
end
