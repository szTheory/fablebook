defmodule OperatorHost.Book do
  @moduledoc false

  @doc false
  def __fablebook_book__ do
    %{
      id: "operator",
      title: "Logistify operator console",
      description:
        "A short dispatcher recovery flow from a fictional demo brand. The name is not cleared for real-world use.",
      path: "/admin/dev/fablebook",
      story_modules: [OperatorHost.Book.DispatcherRecovery]
    }
  end
end

defmodule OperatorHost.Book.DispatcherRecovery do
  use Fablebook.Story

  @source_commit "6189eb2f013496644ece948f287d69a6695c1156"
  @source_file "records/logistify/logistify-records.json"
  @source_url "https://github.com/szTheory/logistify-brand/blob/#{@source_commit}/#{@source_file}"

  @scenario title: "A failed shipment",
            desc: "A failed driver stop reaches the dispatcher, who sees the shipment as Failed.",
            state: :failed
  def failed_shipment do
    %{
      id: "failed_shipment",
      title: "A failed shipment",
      status: "Failed",
      summary: "Nobody was at the dock.",
      facts: [
        %{label: "Shipment", value: "LGX-0417-DE"},
        %{label: "Route", value: "Hamburg to Lyon"},
        %{label: "Driver before reassignment", value: "M. Keller"},
        %{label: "Failure reported", value: "2026-11-10 14:20 +01:00"}
      ],
      action: ["Reassign", "Try again"],
      citations: [
        citation("/flows/1", "Dispatcher recovery flow"),
        citation("/cases/9", "A failed shipment"),
        citation("/shipments/0", "LGX-0417-DE"),
        citation("/drivers/0", "M. Keller"),
        citation("/events/2", "Failure event"),
        citation("/copy/console-failed-note", "Failure message"),
        citation("/copy/console-failed-reassign", "Reassign action"),
        citation("/copy/console-failed-retry", "Try again action")
      ]
    }
  end

  @scenario title: "Twelve shipments reassigned",
            desc: "The dispatcher sees the bulk reassignment result and the source gaps.",
            state: :complete
  def bulk_reassignment do
    %{
      id: "bulk_reassignment",
      title: "Twelve shipments reassigned",
      status: "Illustrative result",
      summary: "The source flow reports 12 shipments reassigned after the bulk Reassign action.",
      facts: [
        %{label: "Bulk count", value: "12 selected"},
        %{label: "Result", value: "12 shipments reassigned"},
        %{label: "Shipment IDs listed in the bulk case", value: "LGX-0417-DE, LGX-0398-FR"},
        %{label: "Other shipment identifiers", value: "Not provided in source"},
        %{label: "Replacement driver", value: "Not provided in source"}
      ],
      action: ["Reassign"],
      citations: [
        citation("/flows/1", "Dispatcher recovery flow"),
        citation("/cases/7", "Bulk selection and listed IDs"),
        citation("/cases/8", "Reassignment result"),
        citation("/copy/console-bulk-count", "Bulk count"),
        citation("/copy/console-bulk-reassign", "Reassign action")
      ]
    }
  end

  defp citation(pointer, section) do
    %{path: @source_file, section: "#{section} — JSON Pointer #{pointer}", url: @source_url}
  end
end
