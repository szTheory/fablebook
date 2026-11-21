defmodule Fablebook.Contract.MountLiteralASTTest.Probe do
  @moduledoc false

  defmacro local_probe_book do
    send(self(), :disallowed_book_macro_expanded)
    quote(do: Fablebook.Contract.MountLiteralASTTest.Book)
  end

  defmacro remote_probe_book do
    send(self(), :disallowed_book_macro_expanded)
    quote(do: Fablebook.Contract.MountLiteralASTTest.Book)
  end
end

defmodule Fablebook.Contract.MountLiteralASTTest.Book do
  @moduledoc false
end

defmodule Fablebook.Contract.MountLiteralASTTest do
  use ExUnit.Case, async: false

  alias Fablebook.Contract.MountLiteralASTTest.Book, as: BookAlias
  alias Fablebook.Contract.MountLiteralASTTest.Probe

  @caller_line 317
  @diagnostic "Book must be a literal module alias or module reference"

  test "accepts a caller alias, a fully qualified alias, and a literal module atom" do
    assert mounted_book(quote(do: BookAlias)) == BookAlias

    assert mounted_book(quote(do: Fablebook.Contract.MountLiteralASTTest.Book)) == BookAlias

    assert mounted_book(BookAlias) == BookAlias
  end

  test "rejects variables, attributes, computed aliases, calls, and non-module literals" do
    variable = {:book, [line: @caller_line], nil}
    attribute = {:@, [line: @caller_line], [{:book, [line: @caller_line], nil}]}

    dynamic_alias =
      {:__aliases__, [line: @caller_line], [{:component, [line: @caller_line], nil}, :Book]}

    computed = quote(do: Enum.at([BookAlias], 0))
    local_macro = quote(do: local_probe_book())
    remote_macro = quote(do: Probe.remote_probe_book())

    Enum.each(
      [
        {"variable", variable},
        {"module attribute", attribute},
        {"dynamic alias component", dynamic_alias},
        {"computed value", computed},
        {"local macro call", local_macro},
        {"remote macro call", remote_macro},
        {"nil", nil},
        {"true", true},
        {"false", false},
        {"string", "Book"},
        {"integer", 1}
      ],
      fn {label, book_ast} ->
        assert_rejected(book_ast, label)
      end
    )
  end

  @tag :mount_rejection_probe
  test "rejects the harmless local expansion probe before executing it" do
    assert_rejected(quote(do: local_probe_book()), "local macro probe")
  end

  defp assert_rejected(book_ast, label) do
    result =
      try do
        {:expanded, expand_mount(book_ast)}
      rescue
        error in CompileError -> {:raised, error}
      end

    refute_received :disallowed_book_macro_expanded, "disallowed Book macro expanded"

    assert {:raised, %CompileError{} = error} = result,
           "expected #{label} to raise a caller-located CompileError"

    assert error.file == __ENV__.file
    assert error.line == @caller_line
    assert error.description =~ @diagnostic
  end

  defp mounted_book(book_ast) do
    expansion = expand_mount(book_ast)
    args = find_router_get_args(expansion)

    assert ["/fablebook", _placeholder, book, [as: :fablebook]] = args
    book
  end

  defp expand_mount(book_ast) do
    ast =
      quote do
        Fablebook.Router.fablebook("/fablebook", unquote(book_ast))
      end

    Macro.expand_once(ast, caller_env())
  end

  defp caller_env do
    env = %{__ENV__ | function: {:fablebook, 2}, line: @caller_line}
    {:ok, env} = Macro.Env.define_require(env, [], Fablebook.Router)
    {:ok, env} = Macro.Env.define_require(env, [], Probe)
    {:ok, env} = Macro.Env.define_import(env, [], Probe)
    env
  end

  defp find_router_get_args({:__block__, _, expressions}) do
    Enum.find_value(expressions, &find_router_get_args/1) ||
      flunk("expected Fablebook.Router to emit a Phoenix.Router.get call")
  end

  defp find_router_get_args({{:., _, [_router, :get]}, _, args}), do: args
  defp find_router_get_args(_other), do: nil
end
