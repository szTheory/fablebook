defmodule Fablebook.Router do
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
      book = Macro.expand(book, %{__CALLER__ | function: {:fablebook, 2}})

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
end
