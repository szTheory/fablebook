defmodule Fablebook.GuardFixture.MixCompilersElixirCompile do
  def run(manifest, srcs, dest, cache_key, parent_manifests, parents, opts),
    do:
      Mix.Compilers.Elixir.compile(
        manifest,
        srcs,
        dest,
        cache_key,
        parent_manifests,
        parents,
        opts
      )
end
