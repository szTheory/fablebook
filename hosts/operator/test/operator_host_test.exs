defmodule OperatorHost.OperatorBookTest do
  use ExUnit.Case, async: false
  import Plug.Conn
  import Phoenix.ConnTest

  @endpoint OperatorHost.Endpoint
  @root "/admin/dev/fablebook"
  @commit "6189eb2f013496644ece948f287d69a6695c1156"
  @scenario "/admin/dev/fablebook/canvas/operator/dispatcher_recovery/failed_shipment"
  @app_css Path.expand("../priv/static/assets/app.css", __DIR__)
  @source_manifest Path.expand(
                     "../../../.planning/phases/08-first-inspectable-book-and-local-host-path/08-LOGISTIFY-SOURCE.json",
                     __DIR__
                   )
  @source_records Path.expand(
                    "../../../.cache/brand_sources/logistify-brand/records/logistify/logistify-records.json",
                    __DIR__
                  )

  @source_expectations %{
    "failed_shipment" => %{
      title: "A failed shipment",
      description:
        "A failed driver stop reaches the dispatcher, who sees the shipment as Failed.",
      status: "Failed",
      summary: "Nobody was at the dock.",
      facts: [
        {"Shipment", "LGX-0417-DE"},
        {"Route", "Hamburg to Lyon"},
        {"Driver before reassignment", "M. Keller"},
        {"Failure reported", "2026-11-10 14:20 +01:00"}
      ],
      actions: ["Reassign", "Try again"],
      pointers: [
        "/flows/1",
        "/cases/9",
        "/shipments/0",
        "/drivers/0",
        "/events/2",
        "/copy/console-failed-note",
        "/copy/console-failed-reassign",
        "/copy/console-failed-retry"
      ],
      text: [
        {"A failed shipment", "/cases/9"},
        {"Failed", "/shipments/0"},
        {"Nobody was at the dock.", "/copy/console-failed-note"},
        {"LGX-0417-DE", "/shipments/0"},
        {"Hamburg to Lyon", "/shipments/0"},
        {"M. Keller", "/drivers/0"},
        {"2026-11-10 14:20 +01:00", "/events/2"},
        {"Reassign", "/copy/console-failed-reassign"},
        {"Try again", "/copy/console-failed-retry"}
      ]
    },
    "bulk_reassignment" => %{
      title: "Twelve shipments reassigned",
      description: "The dispatcher sees the bulk reassignment result and the source gaps.",
      status: "Illustrative result",
      summary: "The source flow reports 12 shipments reassigned after the bulk Reassign action.",
      facts: [
        {"Bulk count", "12 selected"},
        {"Result", "12 shipments reassigned"},
        {"Shipment IDs listed in the bulk case", "LGX-0417-DE, LGX-0398-FR"},
        {"Other shipment identifiers", "Not provided in source"},
        {"Replacement driver", "Not provided in source"}
      ],
      actions: ["Reassign"],
      pointers: [
        "/flows/1",
        "/cases/7",
        "/cases/8",
        "/copy/console-bulk-count",
        "/copy/console-bulk-reassign"
      ],
      text: [
        {"Twelve shipments reassigned", "/cases/8"},
        {"The source flow reports 12 shipments reassigned after the bulk Reassign action.",
         "/flows/1"},
        {"12 selected", "/copy/console-bulk-count"},
        {"12 shipments reassigned", "/cases/8"},
        {"LGX-0417-DE", "/cases/7"},
        {"LGX-0398-FR", "/cases/7"},
        {"Not provided in source", "/cases/7"},
        {"Not provided in source", "/cases/8"},
        {"Reassign", "/copy/console-bulk-reassign"}
      ]
    }
  }

  test "the UI catalog opens the first Scenario beside its sidebar tree" do
    conn = get(build_conn(), @root)
    body = html_response(conn, 200)

    assert body =~ "Books"
    assert body =~ "Logistify operator console"
    assert body =~ "alt=\"Fablebook UI catalog\""
    assert body =~ "Dispatcher recovery"
    assert body =~ "A failed shipment"
    assert body =~ "Twelve shipments reassigned"
    assert body =~ "aria-current=\"page\""
    assert body =~ "aria-label=\"Breadcrumb\""
    assert body =~ "aria-label=\"Scenarios in Dispatcher recovery\""
    assert body =~ "Journey"
    refute body =~ ">Story</span>"

    assert body =~
             "href=\"#{@root}/book/operator/journey/dispatcher_recovery?scenario=failed_shipment\""

    assert body =~ "src=\"#{@scenario}\""
    refute body =~ "Open operator Book"
    assert body =~ "data-operator-root"
    assert get_resp_header(conn, "content-security-policy") != []
  end

  test "the Books navigation explains when no Book is compiled" do
    {:ok, socket} = Fablebook.BookLive.mount(%{}, %{}, %Phoenix.LiveView.Socket{})
    socket = Phoenix.Component.assign(socket, :live_action, :catalog)

    {:noreply, socket} =
      Fablebook.BookLive.handle_params(%{}, "http://localhost/admin/dev/fablebook", socket)

    html =
      socket.assigns
      |> Fablebook.BookLive.render()
      |> Phoenix.HTML.Safe.to_iodata()
      |> IO.iodata_to_binary()

    assert html =~ "aria-label=\"Books\""
    assert html =~ "No Book is available"
    assert html =~ "This development host has no compiled Book to display."
    assert html =~ "No compiled Book is available."
    refute html =~ "data-canvas-frame"
  end

  test "the fixed Scenario resolves through the actual host Canvas" do
    conn = get(build_conn(), @scenario)
    body = html_response(conn, 200)

    assert body =~ "data-canvas-document"
    assert body =~ "data-screen=\"failed_shipment\""
    assert body =~ "LGX-0417-DE"
    assert body =~ "Hamburg to Lyon"
    assert body =~ "Nobody was at the dock."
    assert body =~ "Illustrative records and actions · no live dispatch or external changes."
    refute body =~ "records/logistify/logistify-records.json"
    refute body =~ "JSON Pointer"
    refute body =~ "https://github.com/szTheory/logistify-brand/blob/#{@commit}/"
    assert body =~ "data-operator-root"
    assert get_resp_header(conn, "x-frame-options") == ["SAMEORIGIN"]
    assert get_resp_header(conn, "content-security-policy") != []

    assert body =~ "A failed shipment — Logistify operator console"
    assert body =~ "— Fablebook</title>"
  end

  test "both fixed Scenarios put the exact illustrative notice in a footer landmark" do
    for scenario_id <- ["failed_shipment", "bulk_reassignment"] do
      body =
        get(
          build_conn(),
          "#{@root}/canvas/operator/dispatcher_recovery/#{scenario_id}"
        )
        |> html_response(200)

      assert_canvas_notice_footer(body)
    end
  end

  test "catalog chrome meets the approved contrast, target, type, and spacing scales" do
    css = File.read!(@app_css)
    declared_colors = ["#f6f4ef", "#ffffff", "#17181c", "#d9d6ce", "#b42318"]

    boundaries = [
      {".catalog-sidebar", "border-right", ".catalog-main", "background"},
      {".catalog-sidebar", "border-bottom", ".catalog-main", "background"},
      {".journey-link[aria-current=\"page\"]", "border-color",
       ".journey-link[aria-current=\"page\"]", "background"},
      {".scenario-link[aria-current=\"page\"]", "border-color",
       ".scenario-link[aria-current=\"page\"]", "background"},
      {".journey-scenario-card", "border", ".catalog-main", "background"},
      {".scenario-option[aria-current=\"page\"]", "border-color",
       ".scenario-option[aria-current=\"page\"]", "background"},
      {".empty-state", "border", ".catalog-main", "background"},
      {".unavailable-state", "border", ".catalog-main", "background"},
      {".canvas-shell", "border", ".canvas-shell", "background"}
    ]

    for {selector, border_property, background_selector, background_property} <- boundaries do
      border_color = css_declaration(css, selector, border_property) |> css_hex_color()

      background_color =
        css_declaration(css, background_selector, background_property) |> css_hex_color()

      assert border_color in declared_colors
      assert contrast_ratio(border_color, background_color) >= 3
    end

    focus_color = css_declaration(css, "a:focus-visible", "outline") |> css_hex_color()
    focus_backgrounds = [".catalog-sidebar", ".catalog-main"]

    assert css_declaration(css, "a:focus-visible", "outline-offset") == "4px"

    for selector <- focus_backgrounds do
      background_color = css_declaration(css, selector, "background") |> css_hex_color()
      assert contrast_ratio(focus_color, background_color) >= 3
    end

    assert css_declaration(css, ".catalog-brand", "min-height") == "44px"
    assert css_declaration(css, ".scenario-option", "min-height") == "44px"

    catalog_css =
      css
      |> String.split(".operator-preview {", parts: 2)
      |> hd()
      |> then(&Regex.replace(~r/@font-face\s*\{[^}]*\}/s, &1, ""))
      |> then(&Regex.replace(~r/\.visually-hidden\s*\{[^}]*\}/s, &1, ""))

    sizes =
      Regex.scan(~r/\bfont-size:\s*([^;]+);/, catalog_css, capture: :all_but_first)
      |> List.flatten()
      |> Enum.map(&String.trim/1)

    weights =
      Regex.scan(~r/\bfont-weight:\s*([^;]+);/, catalog_css, capture: :all_but_first)
      |> List.flatten()
      |> Enum.map(&String.trim/1)

    assert Enum.all?(sizes, &(&1 in ["13px", "14px", "16px", "22px"]))
    assert Enum.all?(weights, &(&1 in ["400", "600"]))

    for selector <- [
          ".tree-kind",
          ".tree-empty",
          ".journey-scenario-description",
          ".scenario-navigation-label",
          "#canvas-status"
        ] do
      muted_color = css_declaration(css, selector, "color") |> css_hex_color()
      assert muted_color in declared_colors
    end

    mobile_css =
      case Regex.run(~r/@media\s*\(max-width:\s*720px\)\s*\{(.*)\n\}/s, css,
             capture: :all_but_first
           ) do
        [media_css] -> media_css
        _ -> flunk("mobile catalog rules were not found")
      end

    spacing_declarations =
      [catalog_css, mobile_css]
      |> Enum.flat_map(fn source ->
        Regex.scan(
          ~r/(?:^|[;{])\s*(?:gap|row-gap|column-gap|margin(?:-[a-z-]+)?|padding(?:-[a-z-]+)?)\s*:\s*([^;}]+)/m,
          source
        )
        |> Enum.map(fn [_, value] -> String.trim(value) end)
      end)

    for declaration <- spacing_declarations do
      refute Regex.match?(~r/\b(?:2|6|10)px\b|\b\d+(?:\.\d+)?vw\b/, declaration)

      for [_, amount, unit] <- Regex.scan(~r/(-?\d+(?:\.\d+)?)(px|vw|vh|rem|em|%)/, declaration) do
        assert unit == "px"
        assert rem(String.to_integer(amount), 4) == 0
      end
    end

    assert "minmax(0, 1fr)" in css_declarations(css, ".ui-catalog", "grid-template-columns")
    assert "wrap" in css_declarations(css, ".breadcrumbs ol", "flex-wrap")
    assert "wrap" in css_declarations(css, ".scenario-navigation ul", "flex-wrap")
    assert "anywhere" in css_declarations(css, ".scenario-option", "overflow-wrap")

    for selector <- [".catalog-sidebar", ".catalog-main", ".canvas-shell"] do
      assert "0" in css_declarations(css, selector, "min-width")
    end

    assert "8px 16px 16px" in css_declarations(css, ".catalog-main", "padding")
    assert "4px" in css_declarations(css, ".canvas-shell", "padding")
    assert "4px" in css_declarations(css, ".scenario-option", "padding")
  end

  test "the Canvas status stays accessible without a visible label or loading line" do
    body =
      get(
        build_conn(),
        "#{@root}/book/operator/journey/dispatcher_recovery?scenario=failed_shipment"
      )
      |> html_response(200)

    refute body =~ ~r/<h2[^>]*>\s*Canvas\s*<\/h2>/
    assert body =~ "aria-label=\"Scenario screen\""

    assert body =~
             ~r/<p\b(?=[^>]*\bid=\"canvas-status\")(?=[^>]*\bclass=\"visually-hidden\")(?=[^>]*\brole=\"status\")(?=[^>]*\baria-live=\"polite\")[^>]*>/

    assert body =~ "Loading screen: A failed shipment…"

    css = File.read!(@app_css)
    assert css =~ ~r/\.visually-hidden\s*\{[^}]*clip:\s*rect\(0,\s*0,\s*0,\s*0\)/s

    app_js = File.read!(Path.expand("../priv/static/assets/app.js", __DIR__))
    assert app_js =~ "status.classList.toggle(\"visually-hidden\", state !== \"failed\")"
  end

  test "a source-backed Canvas renders the same cited screen on repeat visits" do
    bodies =
      for _visit <- 1..2 do
        get(build_conn(), @scenario) |> html_response(200)
      end

    [first, second] =
      Enum.map(bodies, fn body ->
        [article | _] = Regex.run(~r/(<article class="operator-content".*?<\/article>)/s, body)
        article
      end)

    assert first == second
  end

  test "an empty source collection keeps the screen citation and names the empty state" do
    scenario = %{
      id: "empty_source",
      title: "No source rows",
      status: "Illustrative",
      summary: nil,
      facts: [],
      action: [],
      citations: [
        %{
          path: "records/logistify/logistify-records.json",
          section: "Empty source fixture",
          url:
            "https://github.com/szTheory/logistify-brand/blob/#{@commit}/records/logistify/logistify-records.json"
        }
      ]
    }

    html =
      Fablebook.BookLive.render(%{
        live_action: :canvas,
        scenario_result: scenario,
        scenario_id: scenario.id,
        unavailable: false
      })
      |> Phoenix.HTML.Safe.to_iodata()
      |> IO.iodata_to_binary()

    assert html =~ "No source-backed details are available for this screen."
    refute html =~ "records/logistify/logistify-records.json"
    refute html =~ "JSON Pointer"
    assert [citation] = scenario.citations
    assert citation.path == "records/logistify/logistify-records.json"
    assert citation.section == "Empty source fixture"
    refute html =~ "aria-label=\"Illustrative actions\""
  end

  test "scenario fact collections preserve zero, one, and many long rows" do
    long_label = String.duplicate("Shipment identity ", 16)
    long_id = "LGX" <> String.duplicate("X", 160)

    collections = [
      [],
      [%{label: long_label, value: long_id}],
      [
        %{label: "Route", value: "Hamburg to Lyon"},
        %{label: "Status", value: "Reassigned"},
        %{label: "Shipment", value: long_id}
      ]
    ]

    rendered =
      for facts <- collections do
        html =
          Fablebook.BookLive.render(%{
            live_action: :canvas,
            scenario_result: %{
              id: "row-counts",
              title: "A source-grounded screen",
              status: "Illustrative",
              summary: nil,
              facts: facts,
              action: []
            },
            scenario_id: "row-counts",
            unavailable: false
          })
          |> Phoenix.HTML.Safe.to_iodata()
          |> IO.iodata_to_binary()

        assert html =~ "<dl class=\"record-facts\">"
        assert length(Regex.scan(~r/<dt>/, html)) == length(facts)
        assert length(Regex.scan(~r/<dd>/, html)) == length(facts)

        if facts == [] do
          assert html =~ "No source-backed details are available for this screen."
        else
          refute html =~ "No source-backed details are available for this screen."
        end

        html
      end

    assert Enum.at(rendered, 1) =~ long_label
    assert Enum.at(rendered, 1) =~ long_id
    assert Enum.at(rendered, 2) =~ long_id

    css = File.read!(@app_css)
    assert css =~ ~r/\.operator-preview\s*\{[^}]*overflow-wrap:\s*anywhere/s
    assert css =~ ~r/\.record-facts dd\s*\{[^}]*overflow-wrap:\s*anywhere/s
  end

  test "the Journey opens its Scenarios in the main panel" do
    body =
      get(build_conn(), "#{@root}/book/operator/journey/dispatcher_recovery")
      |> html_response(200)

    assert body =~ "class=\"journey-view\""
    assert body =~ "<h1>Dispatcher recovery</h1>"
    assert body =~ "<h2 id=\"journey-scenarios-heading\">Scenarios</h2>"
    assert body =~ "class=\"journey-scenario-card\""

    assert body =~
             "href=\"#{@root}/book/operator/journey/dispatcher_recovery?scenario=failed_shipment\""

    assert body =~
             "href=\"#{@root}/book/operator/journey/dispatcher_recovery?scenario=bulk_reassignment\""

    assert body =~ "A failed driver stop reaches the dispatcher"
    assert body =~ "aria-current=\"page\">Dispatcher recovery</span>"
    refute body =~ "data-canvas-frame"
  end

  test "main surfaces stay white and selected sidebar items keep the bookmark marker" do
    css = File.read!(@app_css)

    assert css =~ ~r/\.catalog-main\s*\{[^}]*background:\s*#fff;/s
    assert css =~ ~r/\.canvas-document\s*\{[^}]*background:\s*#fff;/s
    assert css =~ ~r{\.journey-link\[aria-current="page"\]::before}
    assert css =~ ~r{\.scenario-link\[aria-current="page"\]::before}
    assert css =~ ~r{clip-path:\s*polygon\(0 0, 100% 0, 100% 100%, 50% 78%, 0 100%\)}
  end

  test "the Scenario breadcrumb keeps the Book static and Journey useful" do
    body =
      get(
        build_conn(),
        "#{@root}/book/operator/journey/dispatcher_recovery?scenario=bulk_reassignment"
      )
      |> html_response(200)

    [breadcrumbs] =
      Regex.run(~r{<nav[^>]*aria-label="Breadcrumb"[^>]*>(.*?)</nav>}s, body,
        capture: :all_but_first
      )

    refute Regex.match?(
             ~r{<a[^>]*>\s*Logistify operator console\s*</a>},
             breadcrumbs
           )

    assert breadcrumbs =~ "<span>Logistify operator console</span>"
    assert breadcrumbs =~ "aria-current=\"page\">Twelve shipments reassigned</span>"
    assert body =~ "href=\"#{@root}/book/operator/journey/dispatcher_recovery\""
    assert body =~ "aria-label=\"Scenarios in Dispatcher recovery\""

    assert body =~
             "href=\"#{@root}/book/operator/journey/dispatcher_recovery?scenario=failed_shipment\""

    assert body =~
             "href=\"#{@root}/book/operator/journey/dispatcher_recovery?scenario=bulk_reassignment\""

    refute body =~ ">Story</span>"

    book_body =
      get(build_conn(), "#{@root}/book/operator")
      |> html_response(200)

    assert book_body =~ "src=\"#{@scenario}\""
  end

  test "unknown and missing selections show the safe unavailable path" do
    for path <- [
          "#{@root}/book",
          "#{@root}/book/Operator",
          "#{@root}/book/operator/journey/unknown",
          "#{@root}/book/operator/journey/%64ispatcher_recovery",
          "#{@root}/book/operator?scenario=%66ailed_shipment",
          "#{@root}/canvas/operator/dispatcher_recovery/unknown",
          "#{@root}/canvas/operator/dispatcher_recovery/%66ailed_shipment",
          "#{@root}/canvas"
        ] do
      body = get(build_conn(), path) |> html_response(200)

      assert body =~
               "This screen is unavailable in this Book. Choose an available Scenario from the sidebar."

      assert body =~ "Return to Books"
      assert body =~ "href=\"#{@root}\""
    end
  end

  test "the bulk Scenario shows only sourced IDs and labels the source gaps" do
    path = "/admin/dev/fablebook/canvas/operator/dispatcher_recovery/bulk_reassignment"
    body = get(build_conn(), path) |> html_response(200)

    assert body =~ "12 selected"
    assert body =~ "12 shipments reassigned"
    assert body =~ "LGX-0417-DE, LGX-0398-FR"
    assert body =~ "Other shipment identifiers"
    assert body =~ "Replacement driver"
    assert body =~ "Not provided in source"
  end

  test "displayed Scenario facts stay pinned without exposing raw source pointers" do
    manifest = @source_manifest |> File.read!() |> Jason.decode!()
    records = @source_records |> File.read!() |> Jason.decode!()

    manifest_pointers =
      manifest["sources"]
      |> Enum.find(&(&1["path"] == "records/logistify/logistify-records.json"))
      |> Map.fetch!("excerpts")
      |> Map.new(&{&1["citation"], &1})

    {:ok, catalog} = Fablebook.Catalog.build(OperatorHost.Book)

    scenarios =
      for(story <- catalog.stories, scenario <- story.scenarios, do: scenario)
      |> Map.new(&{&1.id, &1})

    for {scenario_id, expected} <- @source_expectations do
      scenario_entry = Map.fetch!(scenarios, scenario_id)
      scenario = apply(scenario_entry.module, scenario_entry.function, [])
      body = get(build_conn(), scenario_path(scenario_id)) |> html_response(200)

      book_body =
        get(
          build_conn(),
          "#{@root}/book/operator/journey/#{scenario_entry.story_id}?scenario=#{scenario_id}"
        )
        |> html_response(200)

      assert scenario_entry.title == expected.title
      assert scenario_entry.description == expected.description
      assert scenario.title == expected.title
      assert scenario.status == expected.status
      assert scenario.summary == expected.summary
      assert Enum.map(scenario.facts, &{&1.label, &1.value}) == expected.facts
      assert scenario.action == expected.actions
      assert body =~ expected.title
      assert body =~ expected.status
      assert body =~ expected.summary
      refute body =~ "records/logistify/logistify-records.json"
      refute body =~ "JSON Pointer"
      assert book_body =~ expected.title
      assert book_body =~ expected.description

      actual_pointers =
        scenario.citations
        |> Enum.map(fn citation ->
          [pointer] =
            Regex.run(~r/JSON Pointer (\/[^ ]+)/, citation.section, capture: :all_but_first)

          pointer
        end)

      assert MapSet.new(actual_pointers) == MapSet.new(expected.pointers)

      for pointer <- expected.pointers do
        excerpt = Map.fetch!(manifest_pointers, "pointer: #{pointer}")
        source_value = resolve_pointer(records, pointer)
        assert source_value != :missing

        excerpt_value = excerpt |> Map.fetch!("base64") |> Base.decode64!() |> Jason.decode!()
        assert excerpt_value == source_value

        assert is_binary(excerpt["claim"]) and excerpt["claim"] != ""
      end

      for {text, pointer} <- expected.text do
        source_value = resolve_pointer(records, pointer)

        assert source_value_matches_display?(text, pointer, source_value, records),
               "#{inspect(text)} is not supported by JSON Pointer #{pointer}"

        assert body =~ text
        assert Enum.member?(actual_pointers, pointer)
      end
    end
  end

  test "the compiled catalog compares route IDs exactly" do
    assert {:ok, catalog} = Fablebook.Catalog.build(OperatorHost.Book)

    assert {:ok, %{function: :failed_shipment}} =
             Fablebook.Catalog.resolve(
               catalog,
               "operator",
               "dispatcher_recovery",
               "failed_shipment"
             )

    assert :error =
             Fablebook.Catalog.resolve(
               catalog,
               "Operator",
               "dispatcher_recovery",
               "failed_shipment"
             )

    assert :error =
             Fablebook.Catalog.resolve(
               catalog,
               "operator",
               "Dispatcher_Recovery",
               "failed_shipment"
             )

    assert :error =
             Fablebook.Catalog.resolve(
               catalog,
               "operator",
               "dispatcher_recovery",
               "failed%5Fshipment"
             )

    assert :error = Fablebook.Catalog.resolve(catalog, "operator", "dispatcher_recovery", "")
  end

  test "Scenario selection carries the Journey when function names repeat" do
    {:ok, socket} =
      Fablebook.BookLive.mount(
        %{},
        %{"book" => OperatorHost.Book.MultiJourneyFixture},
        %Phoenix.LiveView.Socket{}
      )

    socket = Phoenix.Component.assign(socket, :live_action, :journey)

    scenario_uri =
      "http://localhost#{@root}/book/multi_journey_fixture/journey/second_journey?scenario=default"

    {:noreply, selected_socket} =
      Fablebook.BookLive.handle_params(
        %{
          "book_id" => "multi_journey_fixture",
          "story_id" => "second_journey",
          "scenario" => "default"
        },
        scenario_uri,
        socket
      )

    assert selected_socket.assigns.selected_story.id == "second_journey"
    assert selected_socket.assigns.selected_entry.story_id == "second_journey"

    html =
      selected_socket.assigns
      |> Fablebook.BookLive.render()
      |> Phoenix.HTML.Safe.to_iodata()
      |> IO.iodata_to_binary()

    first_path =
      "#{@root}/book/multi_journey_fixture/journey/first_journey?scenario=default"

    second_path =
      "#{@root}/book/multi_journey_fixture/journey/second_journey?scenario=default"

    assert html =~ "href=\"#{first_path}\""
    assert html =~ "href=\"#{second_path}\""

    scenario_links = Regex.scan(~r/<a\b[^>]*class=\"scenario-link\"[^>]*>/, html)
    assert length(scenario_links) == 2
    assert Enum.count(scenario_links, &String.contains?(hd(&1), "aria-current=\"page\"")) == 1
    assert Enum.any?(scenario_links, &String.contains?(hd(&1), second_path))

    ambiguous_socket = Phoenix.Component.assign(socket, :live_action, :book)

    {:noreply, ambiguous_socket} =
      Fablebook.BookLive.handle_params(
        %{"book_id" => "multi_journey_fixture", "scenario" => "default"},
        "http://localhost#{@root}/book/multi_journey_fixture?scenario=default",
        ambiguous_socket
      )

    assert ambiguous_socket.assigns.unavailable
    assert is_nil(ambiguous_socket.assigns.selected_entry)
  end

  test "the host serves same-origin assets used by the root layout" do
    for path <- [
          "/assets/app.css",
          "/assets/app.js",
          "/phoenix/phoenix.js",
          "/phoenix_live_view/phoenix_live_view.js"
        ] do
      conn = get(build_conn(), path)
      assert conn.status == 200
      assert get_resp_header(conn, "content-type") != []
    end
  end

  test "unknown host paths return a normal local 404" do
    conn =
      build_conn()
      |> Plug.Conn.put_req_header("accept", "text/html")
      |> get("/this-route-does-not-exist")

    assert conn.status == 404
    assert html_response(conn, 404) =~ "Not Found"
    assert conn.resp_body =~ "data-operator-root"
    refute conn.resp_body =~ "data-canvas-document"
  end

  defp resolve_pointer(value, pointer) do
    Enum.reduce(String.split(String.trim_leading(pointer, "/"), "/"), value, fn segment,
                                                                                current ->
      case current do
        map when is_map(map) ->
          Map.get(map, segment, :missing)

        list when is_list(list) ->
          case Integer.parse(segment) do
            {index, ""} -> Enum.at(list, index, :missing)
            _ -> :missing
          end

        _ ->
          :missing
      end
    end)
  end

  defp source_value_matches_display?(text, "/events/2", %{"at" => timestamp}, _records) do
    display_timestamp(timestamp) == text
  end

  defp source_value_matches_display?(
         "Twelve shipments reassigned",
         "/cases/8",
         completed_case,
         records
       ) do
    flow = resolve_pointer(records, "/flows/1")
    reassignment = Enum.find(flow["steps"], &(&1["order"] == 4))
    count = get_in(reassignment, ["outcome", "reassignedCount"])

    completed_case["title"] == "Twelve reassigned" and count == 12 and
      String.contains?(completed_case["description"], "#{count} shipments reassigned")
  end

  defp source_value_matches_display?(text, "/flows/1", %{"steps" => steps}, _records) do
    reassignment = Enum.find(steps, &(&1["order"] == 4))
    completed = Enum.find(steps, &(&1["order"] == 5))
    count = get_in(reassignment, ["outcome", "reassignedCount"])
    action = get_in(reassignment, ["action", "label"])
    result_copy = get_in(completed, ["expected"])

    text ==
      "The source flow reports #{count} shipments reassigned after the bulk #{action} action." and
      is_binary(result_copy) and String.contains?(result_copy, "#{count} shipments reassigned")
  end

  defp source_value_matches_display?(
         "Not provided in source",
         "/cases/7",
         %{"records" => %{"shipmentIds" => shipment_ids}},
         records
       ) do
    flow = resolve_pointer(records, "/flows/1")
    reassign_step = Enum.find(flow["steps"], &(&1["order"] == 3))
    selected_count = get_in(reassign_step, ["outcome", "selectedCount"])

    selected_count == 12 and length(shipment_ids) == 2
  end

  defp source_value_matches_display?(
         "Not provided in source",
         "/cases/8",
         completed_case,
         records
       ) do
    flow = resolve_pointer(records, "/flows/1")
    completed_step = Enum.find(flow["steps"], &(&1["order"] == 5))

    source_value_contains?(completed_step["expected"], "new driver") and
      not Map.has_key?(completed_case, "driverId") and
      not Map.has_key?(completed_case, "replacementDriver")
  end

  defp source_value_matches_display?(text, _pointer, source_value, _records) do
    source_value_contains?(source_value, text)
  end

  defp source_value_contains?(value, text) when is_binary(value),
    do: value == text or String.contains?(value, text)

  defp source_value_contains?(value, text) when is_map(value),
    do: Enum.any?(Map.values(value), &source_value_contains?(&1, text))

  defp source_value_contains?(value, text) when is_list(value),
    do: Enum.any?(value, &source_value_contains?(&1, text))

  defp source_value_contains?(_value, _text), do: false

  defp display_timestamp(timestamp) do
    case Regex.run(
           ~r/\A(\d{4}-\d{2}-\d{2})T(\d{2}:\d{2}):\d{2}([+-]\d{2}:\d{2})\z/,
           timestamp
         ) do
      [_, date, time, offset] -> "#{date} #{time} #{offset}"
      _ -> nil
    end
  end

  defp assert_canvas_notice_footer(body) do
    footer_pattern =
      ~r/<footer\b(?=[^>]*\brole="contentinfo")(?=[^>]*\bclass="illustrative-notice")[^>]*>(.*?)<\/footer>/s

    assert length(Regex.scan(footer_pattern, body)) == 1
    assert [_, footer_content] = Regex.run(footer_pattern, body)

    assert String.trim(Regex.replace(~r/<[^>]+>/, footer_content, "")) ==
             "Illustrative records and actions · no live dispatch or external changes."

    {main_end, _} = :binary.match(body, "</main>")
    {footer_start, _} = :binary.match(body, "<footer")
    assert footer_start > main_end
    assert body =~ "data-canvas-document"
  end

  defp css_declarations(css, selector, property) do
    rule_pattern = Regex.compile!("#{Regex.escape(selector)}[^{}]*\\{([^{}]*)\\}", "s")

    declaration_pattern =
      Regex.compile!("(?:^|[;\\n])\\s*#{Regex.escape(property)}\\s*:\\s*([^;]+);")

    Regex.scan(rule_pattern, css)
    |> Enum.flat_map(fn [_, declarations] ->
      Regex.scan(declaration_pattern, declarations, capture: :all_but_first)
      |> List.flatten()
    end)
    |> Enum.map(&String.trim/1)
  end

  defp css_declaration(css, selector, property) do
    css_declarations(css, selector, property) |> List.first()
  end

  defp css_hex_color(value) do
    [color] = Regex.run(~r/#(?:[0-9a-f]{6}|[0-9a-f]{3})\b/i, value)

    case String.downcase(color) do
      <<"#", red::binary-size(1), green::binary-size(1), blue::binary-size(1)>> ->
        "##{red}#{red}#{green}#{green}#{blue}#{blue}"

      full_color ->
        full_color
    end
  end

  defp contrast_ratio(foreground, background) do
    foreground_luminance = relative_luminance(foreground)
    background_luminance = relative_luminance(background)
    brightest = max(foreground_luminance, background_luminance)
    darkest = min(foreground_luminance, background_luminance)

    (brightest + 0.05) / (darkest + 0.05)
  end

  defp relative_luminance(hex) do
    channels =
      hex
      |> String.trim_leading("#")
      |> String.graphemes()
      |> Enum.chunk_every(2)
      |> Enum.map(fn channel -> String.to_integer(Enum.join(channel), 16) / 255 end)
      |> Enum.map(fn channel ->
        if channel <= 0.04045 do
          channel / 12.92
        else
          :math.pow((channel + 0.055) / 1.055, 2.4)
        end
      end)

    Enum.zip([0.2126, 0.7152, 0.0722], channels)
    |> Enum.reduce(0.0, fn {weight, channel}, luminance -> luminance + weight * channel end)
  end

  defp scenario_path(scenario_id),
    do: "/admin/dev/fablebook/canvas/operator/dispatcher_recovery/#{scenario_id}"
end

defmodule OperatorHost.Book.MultiJourneyFixture do
  @moduledoc false

  def __fablebook_book__ do
    %{
      id: "multi_journey_fixture",
      title: "Multi-journey fixture",
      description: "A fixed test Book with repeated Scenario function names.",
      path: "/admin/dev/fablebook",
      story_modules: [
        OperatorHost.Book.MultiJourneyFixture.FirstJourney,
        OperatorHost.Book.MultiJourneyFixture.SecondJourney
      ]
    }
  end
end

defmodule OperatorHost.Book.MultiJourneyFixture.FirstJourney do
  use Fablebook.Story

  @scenario title: "First default", desc: "The default Scenario in the first Journey."
  def default, do: %{id: "first_default", title: "First default"}
end

defmodule OperatorHost.Book.MultiJourneyFixture.SecondJourney do
  use Fablebook.Story

  @scenario title: "Second default", desc: "The default Scenario in the second Journey."
  def default, do: %{id: "second_default", title: "Second default"}
end
