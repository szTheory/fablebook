defmodule Fablebook.GuardFixture.MacroAbsoluteConcat do
  alias String, as: Module

  defmacro run(parts) do
    quote(do: Elixir.Module.concat(unquote(parts)))
  end

  def length(value), do: Module.length(value)
end
