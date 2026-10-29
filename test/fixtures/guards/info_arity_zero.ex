defmodule Fablebook.GuardFixture.InfoArityZero do
  def __info__, do: Function.capture(:file, :script, 1)
end
