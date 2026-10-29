defmodule Fablebook.GuardFixture.CaptureFileScript do
  def run(path, arity), do: Function.capture(:file, :script, arity).(path)
end
