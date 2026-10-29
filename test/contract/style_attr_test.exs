defmodule Fablebook.Contract.StyleAttrTest do
  use ExUnit.Case, async: true

  @lib_patterns [
    {~S|\bstyle\s*=|, ~S|<div style="color: red">|},
    {~S|\bstyle:|, ~S|attrs = [style: "color: red"]|},
    {~S|["']style["']|, ~S|Map.put(attrs, "style", css)|},
    {~S|:style\b|, ~S|Keyword.put(attrs, :style, css)|},
    {~S|<style\b|, ~S|<style>.card { color: red }</style>|}
  ]

  @js_patterns [
    {~S|setAttribute\(\s*["']style|, ~S|el.setAttribute("style", css)|},
    {~S|style\s*=\s*["'`]|, ~S|el.innerHTML = `<b style="color: red">`|},
    {~S|cssText|, ~S|el.style.cssText = css|}
  ]

  @vendored []

  test "lib/ and Fablebook-authored JS carry no inline style" do
    hits =
      scan(Path.wildcard("lib/**/*.{ex,heex}"), @lib_patterns) ++
        scan(Path.wildcard("assets/js/**/*.{js,mjs,ts}"), @js_patterns)

    assert hits == [], "inline style found: #{Enum.join(hits, ", ")}"
  end

  test "every pattern matches its own sample" do
    for {pattern, sample} <- @lib_patterns ++ @js_patterns do
      assert Regex.match?(Regex.compile!(pattern), sample), "#{pattern} misses #{sample}"
    end
  end

  test "CSSOM writes are allowed" do
    refute Enum.any?(@js_patterns, fn {pattern, _} ->
             Regex.match?(Regex.compile!(pattern), ~S|el.style.color = "red"|)
           end)
  end

  defp scan(paths, patterns) do
    regexes = Enum.map(patterns, fn {pattern, _} -> Regex.compile!(pattern) end)

    for path <- paths -- @vendored,
        {line, n} <- path |> File.read!() |> String.split("\n") |> Enum.with_index(1),
        Enum.any?(regexes, &Regex.match?(&1, line)),
        do: "#{path}:#{n}"
  end
end
