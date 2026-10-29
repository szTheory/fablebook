defmodule Fablebook.GuardFixture.DepLockRead do
  def run(lockfile), do: Mix.Dep.Lock.read(lockfile)
end
