defmodule Fablebook.GuardFixture.MacroApplyLoad do
  defmacro run(args) do
    quote(do: apply(:erlang, :load_module, unquote(args)))
  end
end
