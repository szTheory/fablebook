defmodule Fablebook.GuardFixture.FormatDotFormatter do
  def run(file, path), do: Mix.Tasks.Format.formatter_for_file(file, dot_formatter: path)
end
