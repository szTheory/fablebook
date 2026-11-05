defmodule Fablebook.GuardFixture.LeexFileOne do
  def direct(path), do: :leex.file(path)
  def capture, do: &:leex.file/1
  def apply_call(path), do: apply(:leex, :file, [path])
end
