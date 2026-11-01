defmodule Fablebook.Test.MixCmd do
  @moduledoc false

  @scrubbed ~w(MIX_EXS MIX_LOCKFILE MIX_BUILD_PATH MIX_BUILD_ROOT MIX_TARGET FABLEBOOK_UNGUARDED)

  def run(dir, mix_env, args, extra_env \\ []) do
    scrub = Enum.map(@scrubbed, &{&1, nil})

    System.cmd("mix", args,
      cd: dir,
      env: scrub ++ [{"MIX_ENV", mix_env} | extra_env],
      stderr_to_stdout: true
    )
  end
end
