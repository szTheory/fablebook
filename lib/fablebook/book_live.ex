defmodule Fablebook.BookLive do
  @moduledoc false
  use Phoenix.LiveView

  @unavailable "This screen is unavailable in this Book. Choose an available Scenario from the sidebar."

  @impl Phoenix.LiveView
  def mount(_params, %{"book" => book}, socket) when is_atom(book) do
    {:ok, assign_defaults(socket, book)}
  end

  def mount(_params, _session, socket), do: {:ok, assign_defaults(socket, nil)}

  @impl Phoenix.LiveView
  def handle_params(params, uri, socket) do
    case socket.assigns.live_action do
      :catalog ->
        {:noreply, assign_catalog(params, uri, socket)}

      :book ->
        {:noreply, assign_book(params, uri, socket)}

      :journey ->
        {:noreply, assign_journey(params, uri, socket)}

      :canvas ->
        {:noreply, assign_canvas(params, uri, socket)}

      _ ->
        {:noreply, unavailable_socket(socket)}
    end
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <main
      :if={@live_action in [:catalog, :book, :journey]}
      class="ui-catalog"
      data-fablebook-root
      data-book={@book_info && @book_info.id}
    >
      <aside class="catalog-sidebar" aria-label="Fablebook UI catalog navigation">
        <a class="catalog-brand" href={if @book_info, do: book_path(@book_info), else: "/admin/dev/fablebook"}>
          <img
            src="/assets/brand/fablebook-lockup-small-light.svg"
            alt="Fablebook UI catalog"
            width="116"
            height="24"
          />
        </a>

        <nav class="book-tree" aria-label="Books">
          <h2>Books</h2>
          <ul class="book-list">
            <li :if={@book_info}>
              <.link patch={book_path(@book_info)} class="book-link">
                {@book_info.title}
              </.link>
              <ul class="journey-list">
                <li :for={story <- @stories}>
                  <span class="tree-kind">Journey</span>
                  <.link
                    patch={journey_path(@book_info, story)}
                    class="journey-link"
                    aria-current={
                      if @journey_overview && @selected_story && @selected_story.id === story.id,
                        do: "page"
                    }
                  >
                    {story.title}
                  </.link>
                  <span class="tree-kind">Scenarios</span>
                  <ul class="scenario-list">
                    <li :for={entry <- story.scenarios}>
                      <.link
                        patch={book_path(@book_info, entry)}
                        class="scenario-link"
                        aria-current={
                          if @selected_entry && @selected_entry.story_id === story.id &&
                               @selected_entry.id === entry.id,
                            do: "page"
                        }
                      >
                        {entry.title}
                      </.link>
                    </li>
                  </ul>
                </li>
              </ul>
            </li>
            <li :if={is_nil(@book_info)} class="tree-empty">No compiled Book is available.</li>
          </ul>
        </nav>
      </aside>

      <section class="catalog-main" aria-label="Selected screen">
        <.unavailable_state :if={@unavailable} book_info={@book_info} />

        <section :if={@journey_overview && @selected_story} class="journey-view">
          <header class="screen-heading">
            <nav class="breadcrumbs" aria-label="Breadcrumb">
              <ol>
                <li>
                  <span>{@book_info.title}</span>
                  <span aria-hidden="true">/</span>
                </li>
                <li><span aria-current="page">{@selected_story.title}</span></li>
              </ol>
            </nav>
            <h1>{@selected_story.title}</h1>
          </header>

          <section class="journey-scenarios" aria-labelledby="journey-scenarios-heading">
            <h2 id="journey-scenarios-heading">Scenarios</h2>
            <ul class="journey-scenario-list">
              <li :for={entry <- @selected_story.scenarios}>
                <.link patch={book_path(@book_info, entry)} class="journey-scenario-card">
                  <span class="journey-scenario-title">{entry.title}</span>
                  <p class="journey-scenario-description">{entry.description}</p>
                </.link>
              </li>
            </ul>
          </section>
        </section>

        <section :if={@selected_entry && @selected_story} class="screen-view">
          <header class="screen-heading">
            <nav class="breadcrumbs" aria-label="Breadcrumb">
              <ol>
                <li>
                  <span>{@book_info.title}</span>
                  <span aria-hidden="true">/</span>
                </li>
                <li>
                  <.link patch={journey_path(@book_info, @selected_story)}>
                    {@selected_story.title}
                  </.link>
                  <span aria-hidden="true">/</span>
                </li>
                <li><span aria-current="page">{@selected_entry.title}</span></li>
              </ol>
            </nav>

            <nav
              class="scenario-navigation"
              aria-label={"Scenarios in #{@selected_story.title}"}
            >
              <span class="scenario-navigation-label">Scenarios</span>
              <ul>
                <li :for={entry <- @selected_story.scenarios}>
                  <.link
                    patch={book_path(@book_info, entry)}
                    class="scenario-option"
                    aria-current={if entry.id === @selected_entry.id, do: "page"}
                  >
                    {entry.title}
                  </.link>
                </li>
              </ul>
            </nav>

            <h1>{@selected_entry.title}</h1>
            <p class="screen-description">{@selected_entry.description}</p>
          </header>

          <section class="canvas-shell" aria-label="Scenario screen">
            <p
              id="canvas-status"
              class="visually-hidden"
              role="status"
              aria-live="polite"
              data-canvas-status="loading"
            >
              Loading screen: {@selected_entry.title}…
            </p>
            <iframe
              id="book-canvas"
              data-canvas-frame
              data-screen={@selected_entry.id}
              title={"#{@book_info.title} — #{@selected_entry.title}"}
              src={canvas_path(@book_info, @selected_entry)}
            />
          </section>
        </section>

        <section :if={is_nil(@book_info) && !@unavailable} class="empty-state">
          <h1>No Book is available</h1>
          <p>This development host has no compiled Book to display.</p>
        </section>
      </section>
    </main>

    <div :if={@live_action == :canvas} class="canvas-document" data-canvas-document>
      <div
        :if={@scenario_result}
        id="canvas-screen"
        phx-hook="FablebookCanvas"
        data-screen={@scenario_id}
      >
        <%= if match?(%Phoenix.LiveView.Rendered{}, @scenario_result) do %>
          {@scenario_result}
        <% else %>
          <.scenario_content scenario={@scenario_result} />
        <% end %>
      </div>
      <main :if={@unavailable} class="unavailable-page">
        <.unavailable_state book_info={@book_info} />
      </main>
    </div>

    <main :if={@live_action == :unavailable} class="unavailable-page">
      <.unavailable_state book_info={@book_info} />
    </main>
    """
  end

  defp assign_defaults(socket, book_module) do
    assign(socket,
      book_module: book_module,
      book_info: nil,
      catalog: nil,
      stories: [],
      scenarios: [],
      selected_entry: nil,
      selected_story: nil,
      journey_overview: false,
      scenario_result: nil,
      scenario_id: nil,
      unavailable: false,
      page_title: "Fablebook UI catalog"
    )
  end

  defp assign_catalog(params, uri, socket) do
    case Fablebook.Catalog.build(socket.assigns.book_module) do
      {:ok, catalog} ->
        info = catalog.book
        scenarios = scenario_entries(catalog)
        selected_entry = select_entry(scenarios, Map.get(params, "scenario"))

        if canonical_catalog_uri?(uri, info) and selected_entry do
          assign_workbench(socket, catalog, info, selected_entry)
        else
          unavailable_socket(socket)
        end

      {:error, _reason} ->
        assign(socket, catalog: nil, book_info: nil, page_title: "Books")
    end
  end

  defp assign_book(%{"book_id" => book_id} = params, uri, socket) do
    with {:ok, catalog} <- Fablebook.Catalog.build(socket.assigns.book_module),
         {:ok, info} <- Fablebook.Catalog.resolve_book(catalog, book_id),
         scenarios = scenario_entries(catalog),
         selected_entry = select_entry(scenarios, Map.get(params, "scenario")),
         true <- selected_entry != nil,
         true <- canonical_book_uri?(uri, info, selected_entry, Map.has_key?(params, "scenario")) do
      assign_workbench(socket, catalog, info, selected_entry)
    else
      _ -> unavailable_socket(socket)
    end
  end

  defp assign_book(_params, _uri, socket), do: unavailable_socket(socket)

  defp assign_journey(%{"book_id" => book_id, "story_id" => story_id} = params, uri, socket) do
    with {:ok, catalog} <- Fablebook.Catalog.build(socket.assigns.book_module),
         {:ok, info} <- Fablebook.Catalog.resolve_book(catalog, book_id),
         story when not is_nil(story) <- Enum.find(catalog.stories, &(&1.id === story_id)),
         scenario_id = Map.get(params, "scenario"),
         true <- canonical_journey_uri?(uri, info, story, scenario_id) do
      assign_journey_selection(socket, catalog, info, story, scenario_id)
    else
      _ -> unavailable_socket(socket)
    end
  end

  defp assign_journey(_params, _uri, socket), do: unavailable_socket(socket)

  defp assign_journey_selection(socket, catalog, info, story, nil),
    do: assign_journey_overview(socket, catalog, info, story)

  defp assign_journey_selection(socket, catalog, info, story, scenario_id) do
    case select_entry(story.scenarios, scenario_id) do
      nil -> unavailable_socket(socket)
      entry -> assign_workbench(socket, catalog, info, entry)
    end
  end

  defp assign_canvas(
         %{"book_id" => book_id, "story_id" => story_id, "scenario_id" => scenario_id},
         uri,
         socket
       ) do
    with {:ok, catalog} <- Fablebook.Catalog.build(socket.assigns.book_module),
         {:ok, info} <- Fablebook.Catalog.resolve_book(catalog, book_id),
         {:ok, entry} <- Fablebook.Catalog.resolve(catalog, book_id, story_id, scenario_id),
         true <- canonical_canvas_uri?(uri, info, entry) do
      assign(socket,
        catalog: catalog,
        book_info: info,
        stories: catalog.stories,
        scenarios: scenario_entries(catalog),
        scenario_result: invoke_scenario(entry),
        scenario_id: entry.id,
        unavailable: false,
        page_title: "#{entry.title} — #{info.title}"
      )
    else
      _ -> unavailable_socket(socket)
    end
  end

  defp assign_canvas(_params, _uri, socket), do: unavailable_socket(socket)

  defp unavailable_socket(socket) do
    case Fablebook.Catalog.build(socket.assigns.book_module) do
      {:ok, catalog} ->
        assign(socket,
          book_info: catalog.book,
          catalog: catalog,
          stories: catalog.stories,
          scenarios: scenario_entries(catalog),
          selected_entry: nil,
          selected_story: nil,
          journey_overview: false,
          scenario_result: nil,
          scenario_id: nil,
          unavailable: true,
          page_title: "Screen unavailable — Fablebook"
        )

      {:error, _reason} ->
        assign(socket,
          book_info: nil,
          catalog: nil,
          stories: [],
          scenarios: [],
          selected_entry: nil,
          selected_story: nil,
          journey_overview: false,
          scenario_result: nil,
          scenario_id: nil,
          unavailable: true,
          page_title: "Screen unavailable — Fablebook"
        )
    end
  end

  defp assign_journey_overview(socket, catalog, info, story) do
    assign(socket,
      catalog: catalog,
      book_info: info,
      stories: catalog.stories,
      scenarios: scenario_entries(catalog),
      selected_entry: nil,
      selected_story: story,
      journey_overview: true,
      unavailable: false,
      page_title: "#{story.title} — #{info.title}"
    )
  end

  defp assign_workbench(socket, catalog, info, selected_entry) do
    selected_story = Enum.find(catalog.stories, &(&1.id === selected_entry.story_id))

    assign(socket,
      catalog: catalog,
      book_info: info,
      stories: catalog.stories,
      scenarios: scenario_entries(catalog),
      selected_entry: selected_entry,
      selected_story: selected_story,
      journey_overview: false,
      unavailable: false,
      page_title: "#{selected_entry.title} — #{info.title}"
    )
  end

  defp scenario_entries(catalog), do: Enum.flat_map(catalog.stories, & &1.scenarios)

  defp select_entry(scenarios, nil), do: List.first(scenarios)

  defp select_entry(scenarios, requested_id) when is_binary(requested_id) do
    case Enum.filter(scenarios, &(&1.id === requested_id)) do
      [entry] -> entry
      _ -> nil
    end
  end

  defp select_entry(_scenarios, _requested_id), do: nil

  defp invoke_scenario(%{module: module, function: function, arity: 0}) do
    apply(module, function, [])
  end

  defp invoke_scenario(%{module: module, function: function, arity: 1}) do
    apply(module, function, [%{}])
  end

  defp book_path(info), do: "#{info.path}/book/#{info.id}"

  defp book_path(info, entry) do
    "#{journey_path(info, %{id: entry.story_id})}?scenario=#{URI.encode_www_form(entry.id)}"
  end

  defp journey_path(info, story) do
    "#{book_path(info)}/journey/#{URI.encode_www_form(story.id)}"
  end

  defp canvas_path(info, entry) do
    "#{info.path}/canvas/#{info.id}/#{entry.story_id}/#{entry.id}"
  end

  defp canonical_book_uri?(uri, info, entry, scenario_query?) do
    parsed = URI.parse(uri)

    expected_query =
      if scenario_query?, do: "scenario=#{URI.encode_www_form(entry.id)}", else: nil

    parsed.path === book_path(info) and parsed.query === expected_query
  end

  defp canonical_journey_uri?(uri, info, story, scenario_id) do
    parsed = URI.parse(uri)

    expected_query =
      if is_binary(scenario_id), do: "scenario=#{URI.encode_www_form(scenario_id)}", else: nil

    parsed.path === journey_path(info, story) and parsed.query === expected_query
  end

  defp canonical_canvas_uri?(uri, info, entry) do
    parsed = URI.parse(uri)
    parsed.path === canvas_path(info, entry) and is_nil(parsed.query)
  end

  defp canonical_catalog_uri?(uri, info) do
    parsed = URI.parse(uri)
    parsed.path === info.path and is_nil(parsed.query)
  end

  defp unavailable_state(assigns) do
    assigns = assign(assigns, :unavailable_message, @unavailable)

    ~H"""
    <section class="unavailable-state" role="status" aria-live="polite">
      <h1>Screen unavailable</h1>
      <p>{@unavailable_message}</p>
      <a class="text-link" href="/admin/dev/fablebook">Return to Books</a>
    </section>
    """
  end

  defp scenario_content(assigns) do
    ~H"""
    <div class="operator-preview" data-screen={@scenario.id}>
      <main>
        <article class="operator-content">
          <header class="preview-header">
            <p class="preview-brand">Logistify — dispatcher console</p>
            <h1>{@scenario.title}</h1>
            <p class="status-word">{@scenario.status}</p>
          </header>

          <p :if={@scenario.summary} class="preview-summary">{@scenario.summary}</p>

          <dl class="record-facts">
            <div :for={fact <- @scenario.facts}>
              <dt>{fact.label}</dt>
              <dd>{fact.value}</dd>
            </div>
          </dl>

          <p :if={@scenario.facts == []} class="empty-scenario">
            No source-backed details are available for this screen.
          </p>

          <section
            :if={@scenario.action != []}
            class="illustrative-actions"
            aria-label="Illustrative actions"
          >
            <h2>Illustrative actions</h2>
            <span :for={action <- @scenario.action} class="illustrative-action">
              Illustrative: {action}
            </span>
          </section>
        </article>
      </main>

      <footer class="illustrative-notice" role="contentinfo">
        Illustrative records and actions · no live dispatch or external changes.
      </footer>
    </div>
    """
  end
end
