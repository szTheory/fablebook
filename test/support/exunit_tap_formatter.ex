defmodule Fablebook.Test.ExUnitTapFormatter do
  @moduledoc false
  use GenServer

  @impl true
  def init(_options), do: {:ok, []}

  @impl true
  def handle_cast({:test_finished, %ExUnit.Test{} = test}, tests) do
    {:noreply, [test | tests]}
  end

  def handle_cast({:suite_finished, _times}, tests) do
    report = tests |> Enum.reverse() |> tap_report()

    case System.get_env("FABLEBOOK_TAP_REPORT") do
      nil -> IO.write(report)
      "" -> IO.write(report)
      path -> File.write!(path, report)
    end

    {:noreply, tests}
  end

  def handle_cast(_event, tests), do: {:noreply, tests}

  defp tap_report(tests) do
    points = tests |> Enum.with_index(1) |> Enum.map(&tap_point/1)
    ["TAP version 13\n", points, "1..#{length(tests)}\n"] |> IO.iodata_to_binary()
  end

  defp tap_point({test, index}) do
    name = test.name |> to_string() |> String.replace(~r/[\r\n]+/, " ")

    case test.state do
      nil -> ["ok #{index} - #{name}\n"]
      {:skipped, reason} -> skip_point(index, name, reason)
      {:excluded, reason} -> skip_point(index, name, reason)
      state -> failure_point(index, name, state)
    end
  end

  defp skip_point(index, name, reason) do
    ["ok #{index} - #{name} # SKIP ", inspect(reason), "\n"]
  end

  defp failure_point(index, name, state) do
    detail = inspect(state, pretty: true, limit: :infinity, printable_limit: :infinity)
    encoded = Base.encode64(detail)

    [
      "not ok #{index} - #{name}\n",
      "  ---\n",
      "  exunit_state_base64: #{encoded}\n",
      "  ...\n"
    ]
  end
end
