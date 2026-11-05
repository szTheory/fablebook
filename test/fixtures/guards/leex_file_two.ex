defmodule Fablebook.GuardFixture.LeexFileTwo do
  def direct(path, options), do: :leex.file(path, options)
  def capture, do: &:leex.file/2
  def apply_call(path, options), do: apply(:leex, :file, [path, options])
end
