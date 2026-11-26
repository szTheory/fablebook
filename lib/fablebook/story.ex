defmodule Fablebook.Story do
  @moduledoc """
  Collects fixed scenario metadata in a compiled Story module.

  Stories and their scenarios are ordinary compiled Elixir modules and
  functions. This macro records only metadata declared beside those functions;
  it does not load or evaluate source at runtime.
  """

  defmacro __using__(_opts) do
    quote do
      Module.register_attribute(__MODULE__, :fablebook_scenarios, accumulate: true)
      @on_definition {Fablebook.Story, :__on_definition__}
      @before_compile Fablebook.Story
    end
  end

  @doc false
  def __on_definition__(env, _kind, name, args, _guards, _body) do
    case Module.get_attribute(env.module, :scenario) do
      metadata when is_list(metadata) ->
        scenario = %{
          id: Atom.to_string(name),
          function: name,
          arity: length(args),
          metadata: Map.new(metadata)
        }

        Module.put_attribute(env.module, :fablebook_scenarios, scenario)
        Module.delete_attribute(env.module, :scenario)

      _ ->
        :ok
    end
  end

  @doc false
  defmacro __before_compile__(env) do
    scenarios =
      env.module
      |> Module.get_attribute(:fablebook_scenarios)
      |> Enum.reverse()

    story_id =
      case Module.get_attribute(env.module, :fablebook_story_id) do
        id when is_binary(id) and id != "" -> id
        _ -> env.module |> Module.split() |> List.last() |> Macro.underscore()
      end

    quote do
      @doc false
      def __fablebook_story__ do
        %{id: unquote(story_id), module: __MODULE__, scenarios: unquote(Macro.escape(scenarios))}
      end
    end
  end
end
