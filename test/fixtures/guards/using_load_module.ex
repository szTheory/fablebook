defmodule Fablebook.GuardFixture.UsingLoadModule do
  defmacro __using__(_opts) do
    quote do
      def load(m, b), do: :erlang.load_module(m, b)
    end
  end
end
