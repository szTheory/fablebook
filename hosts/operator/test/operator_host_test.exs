defmodule OperatorHost.OperatorBookTest do
  use ExUnit.Case, async: false
  import Plug.Conn
  import Phoenix.ConnTest

  @endpoint OperatorHost.Endpoint
  @root "/admin/dev/fablebook"
  @commit "6189eb2f013496644ece948f287d69a6695c1156"
  @scenario "/admin/dev/fablebook/canvas/operator/dispatcher_recovery/failed_shipment"
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
    assert body =~ "href=\"#{@root}/book/operator?scenario=failed_shipment\""
    assert body =~ "src=\"#{@scenario}\""
    refute body =~ "Open operator Book"
    assert body =~ "data-operator-root"
    assert get_resp_header(conn, "content-security-policy") != []
  end

  test "the fixed Scenario resolves through the actual host Canvas" do
    conn = get(build_conn(), @scenario)
    body = html_response(conn, 200)

    assert body =~ "data-canvas-document"
    assert body =~ "data-screen=\"failed_shipment\""
    assert body =~ "LGX-0417-DE"
    assert body =~ "Hamburg to Lyon"
    assert body =~ "Nobody was at the dock."
    assert body =~ "Illustrative records and actions. No live dispatch or external changes."
    refute body =~ "records/logistify/logistify-records.json"
    refute body =~ "JSON Pointer"
    refute body =~ "https://github.com/szTheory/logistify-brand/blob/#{@commit}/"
    assert body =~ "data-operator-root"
    assert get_resp_header(conn, "x-frame-options") == ["SAMEORIGIN"]
    assert get_resp_header(conn, "content-security-policy") != []

    assert body =~ "A failed shipment — Logistify operator console"
    assert body =~ "— Fablebook</title>"
  end

  test "a source-backed Canvas renders the same cited screen on repeat visits" do
    bodies =
      for _visit <- 1..2 do
        get(build_conn(), @scenario) |> html_response(200)
      end

    [first, second] =
      Enum.map(bodies, fn body ->
        [article | _] = Regex.run(~r/(<article class="operator-preview".*?<\/article>)/s, body)
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

  test "the Book sidebar nests stable Scenario links under its Journey" do
    conn = get(build_conn(), "#{@root}/book/operator")
    body = html_response(conn, 200)

    assert body =~ "aria-label=\"Books\""
    assert body =~ "Logistify operator console"
    assert body =~ "Journey"
    assert body =~ "Dispatcher recovery"
    assert body =~ "class=\"tree-kind\">Scenarios</span>"
    assert body =~ "href=\"#{@root}/book/operator?scenario=failed_shipment\""
    assert body =~ "src=\"#{@scenario}\""
    assert body =~ "title=\"Logistify operator console — A failed shipment\""
    assert body =~ "href=\"#{@root}/book/operator?scenario=bulk_reassignment\""
    assert body =~ "data-canvas-status=\"loading\""
  end

  test "Book and Journey breadcrumbs and sibling Scenario links navigate" do
    body =
      get(build_conn(), "#{@root}/book/operator?scenario=bulk_reassignment")
      |> html_response(200)

    assert body =~ "aria-label=\"Breadcrumb\""
    assert body =~ "href=\"#{@root}/book/operator\""
    assert body =~ "href=\"#{@root}/book/operator?scenario=failed_shipment\""
    assert body =~ "aria-current=\"page\">Twelve shipments reassigned</span>"
    assert body =~ "aria-label=\"Scenarios in Dispatcher recovery\""
    assert body =~ "href=\"#{@root}/book/operator?scenario=bulk_reassignment\""
    refute body =~ ">Story</span>"

    book_body =
      get(build_conn(), "#{@root}/book/operator")
      |> html_response(200)

    journey_body =
      get(build_conn(), "#{@root}/book/operator?scenario=failed_shipment")
      |> html_response(200)

    sibling_body =
      get(build_conn(), "#{@root}/book/operator?scenario=bulk_reassignment")
      |> html_response(200)

    assert book_body =~ "src=\"#{@scenario}\""
    assert journey_body =~ "src=\"#{@scenario}\""
    assert sibling_body =~ "data-screen=\"bulk_reassignment\""
  end

  test "unknown and missing selections show the safe unavailable path" do
    for path <- [
          "#{@root}/book",
          "#{@root}/book/Operator",
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
        get(build_conn(), "#{@root}/book/operator?scenario=#{scenario_id}")
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

  defp scenario_path(scenario_id),
    do: "/admin/dev/fablebook/canvas/operator/dispatcher_recovery/#{scenario_id}"
end
