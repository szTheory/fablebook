defmodule Fablebook.Router do
  @literal_book_error "Book must be a literal module alias or module reference"

  @moduledoc """
  Mounts Fablebook in a Phoenix router.

  Mount it inside the `dev_routes` block that `phx.new` generates, so it is
  never reachable in a prod build:

      if Application.compile_env(:my_app, :dev_routes) do
        import Fablebook.Router

        scope "/dev" do
          pipe_through :browser

          fablebook "/fablebook", MyAppWeb.Storybook
        end
      end

  A mount that a prod build can reach fails to compile.
  """

  @doc """
  Mounts the workbench for `book` at `path`.
  """
  defmacro fablebook(path, book) do
    if Mix.env() == :prod do
      description = prod_description(path, book, Mix.Project.config()[:app])

      quote do
        raise CompileError,
          file: unquote(__CALLER__.file),
          line: unquote(__CALLER__.line),
          description: unquote(description)
      end
    else
      book = resolve_book(book, __CALLER__)

      quote do
        require Phoenix.Router
        Phoenix.Router.get(unquote(path), Fablebook.Placeholder, unquote(book), as: :fablebook)
      end
    end
  end

  defp prod_description(path, book, app) do
    mount = "fablebook #{Macro.to_string(path)}, #{Macro.to_string(book)}"

    """
    Fablebook cannot be mounted in a prod build

        #{mount}

    This mount is reachable when MIX_ENV=prod; move it inside the dev_routes block:

        if Application.compile_env(#{inspect(app)}, :dev_routes) do
          scope "/dev" do
            pipe_through :browser

            #{mount}
          end
        end
    """
  end

  defp resolve_book(book_ast, caller) do
    if literal_book_ast?(book_ast) do
      resolved = Macro.expand(book_ast, %{caller | function: {:fablebook, 2}})

      if module_reference?(resolved) do
        resolved
      else
        raise_book_error(caller)
      end
    else
      raise_book_error(caller)
    end
  end

  defp literal_book_ast?({:__aliases__, _, segments}) when is_list(segments) do
    segments != [] and Enum.all?(segments, &(is_atom(&1) and &1 not in [nil, true, false]))
  end

  defp literal_book_ast?(book), do: module_reference?(book)

  defp module_reference?(module) when is_atom(module) and module not in [nil, true, false] do
    module == Elixir or String.starts_with?(Atom.to_string(module), "Elixir.")
  end

  defp module_reference?(_other), do: false

  defp raise_book_error(caller) do
    raise CompileError,
      file: caller.file,
      line: caller.line,
      description: @literal_book_error
  end
end
