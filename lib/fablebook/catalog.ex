defmodule Fablebook.Catalog do
  @moduledoc """
  Builds a catalog from one compiled Book and its fixed Story module list.

  The result is assembled on demand and contains only compiled module and
  function references declared by the Book. Request strings are resolved by
  exact comparison and are never converted to atoms or modules.
  """

  @type scenario :: %{
          id: String.t(),
          function: atom(),
          arity: 0 | 1,
          module: module(),
          story_id: String.t(),
          title: String.t(),
          description: String.t()
        }

  @type story :: %{id: String.t(), module: module(), title: String.t(), scenarios: [scenario()]}

  @type catalog :: %{book: map(), stories: [story()]}

  @doc "Builds the in-memory catalog from a fixed, compiled Book module."
  @spec build(module()) ::
          {:ok, catalog()} | {:error, :invalid_book | :invalid_story | :duplicate_id}
  def build(book_module) when is_atom(book_module) do
    with true <- Code.ensure_loaded?(book_module),
         true <- function_exported?(book_module, :__fablebook_book__, 0),
         {:ok, book} <- normalize_book(book_module.__fablebook_book__(), book_module),
         {:ok, stories} <- build_stories(book.story_modules, book_module),
         :ok <- ensure_unique_ids(stories) do
      {:ok, %{book: book, stories: stories}}
    else
      false -> {:error, :invalid_book}
      {:error, reason} -> {:error, reason}
      _ -> {:error, :invalid_book}
    end
  end

  def build(_book_module), do: {:error, :invalid_book}

  @doc "Resolves a route selection using exact strings from the compiled catalog."
  @spec resolve(catalog(), String.t(), String.t(), String.t()) :: {:ok, scenario()} | :error
  def resolve(%{book: %{id: book_id}, stories: stories}, book_id, story_id, scenario_id)
      when is_binary(book_id) and is_binary(story_id) and is_binary(scenario_id) do
    Enum.find_value(stories, :error, &matching_story(&1, story_id, scenario_id))
  end

  def resolve(_catalog, _book_id, _story_id, _scenario_id), do: :error

  defp matching_story(%{id: story_id, scenarios: scenarios}, story_id, scenario_id) do
    Enum.find_value(scenarios, &matching_scenario(&1, scenario_id))
  end

  defp matching_story(_story, _story_id, _scenario_id), do: nil

  defp matching_scenario(%{id: scenario_id} = scenario, scenario_id), do: {:ok, scenario}
  defp matching_scenario(_scenario, _scenario_id), do: nil

  @doc "Returns the Book only when its complete fixed route ID matches."
  @spec resolve_book(catalog(), String.t()) :: {:ok, map()} | :error
  def resolve_book(%{book: %{id: id} = book}, id) when is_binary(id), do: {:ok, book}
  def resolve_book(_catalog, _id), do: :error

  defp normalize_book(
         %{id: id, title: title, description: description, path: path, story_modules: modules},
         module
       )
       when is_binary(id) and id != "" and is_binary(title) and is_binary(description) and
              is_binary(path) and is_list(modules) do
    if Enum.all?(modules, &trusted_story_module?(&1, module)) do
      {:ok,
       %{
         id: id,
         title: title,
         description: description,
         path: path,
         module: module,
         story_modules: modules
       }}
    else
      {:error, :invalid_book}
    end
  end

  defp normalize_book(_metadata, _module), do: {:error, :invalid_book}

  defp trusted_story_module?(story_module, book_module) when is_atom(story_module) do
    prefix = Atom.to_string(book_module) <> "."

    Code.ensure_loaded?(story_module) and
      String.starts_with?(Atom.to_string(story_module), prefix) and
      function_exported?(story_module, :__fablebook_story__, 0)
  end

  defp trusted_story_module?(_story_module, _book_module), do: false

  defp build_stories(modules, _book_module) do
    Enum.reduce_while(modules, {:ok, []}, fn module, {:ok, acc} ->
      case build_story(module) do
        {:ok, story} -> {:cont, {:ok, [story | acc]}}
        :error -> {:halt, {:error, :invalid_story}}
      end
    end)
    |> case do
      {:ok, stories} -> {:ok, Enum.reverse(stories)}
      error -> error
    end
  end

  defp build_story(module) do
    metadata = module.__fablebook_story__()

    with %{id: id, scenarios: scenarios} when is_binary(id) and is_list(scenarios) <- metadata,
         true <- id == module |> Module.split() |> List.last() |> Macro.underscore(),
         {:ok, entries} <- build_scenarios(module, id, scenarios) do
      {:ok, %{id: id, module: module, title: humanize(id), scenarios: entries}}
    else
      _ -> :error
    end
  end

  defp build_scenarios(module, story_id, scenarios) do
    Enum.reduce_while(scenarios, {:ok, []}, fn scenario, {:ok, acc} ->
      case build_scenario(module, story_id, scenario) do
        {:ok, entry} -> {:cont, {:ok, [entry | acc]}}
        :error -> {:halt, :error}
      end
    end)
    |> case do
      {:ok, entries} -> {:ok, Enum.reverse(entries)}
      :error -> :error
    end
  end

  defp build_scenario(module, story_id, %{function: function, arity: arity, metadata: metadata})
       when is_atom(function) and arity in [0, 1] and is_map(metadata) do
    title = Map.get(metadata, :title, Map.get(metadata, :desc))
    description = Map.get(metadata, :desc)

    if is_binary(title) and is_binary(description) and description != "" and
         function_exported?(module, function, arity) do
      {:ok,
       %{
         id: Atom.to_string(function),
         function: function,
         arity: arity,
         module: module,
         story_id: story_id,
         title: title,
         description: description
       }}
    else
      :error
    end
  end

  defp build_scenario(_module, _story_id, _scenario), do: :error

  defp ensure_unique_ids(stories) do
    story_ids = Enum.map(stories, & &1.id)

    scenario_ids =
      Enum.flat_map(stories, fn story -> Enum.map(story.scenarios, &{story.id, &1.id}) end)

    if length(story_ids) == length(Enum.uniq(story_ids)) and
         length(scenario_ids) == length(Enum.uniq(scenario_ids)) do
      :ok
    else
      {:error, :duplicate_id}
    end
  end

  defp humanize(id) do
    id
    |> String.replace("_", " ")
    |> String.capitalize()
  end
end
