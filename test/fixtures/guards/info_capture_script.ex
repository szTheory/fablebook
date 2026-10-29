defmodule Fablebook.GuardFixture.InfoCaptureScript do
  def __info__(path, arity), do: Function.capture(:file, :script, arity).(path)
end
