{options, rest, invalid} =
  OptionParser.parse(System.argv(), strict: [root: :string, stage: :string, phase: :string])

if rest != [] or invalid != [] do
  IO.puts(
    :stderr,
    "Usage: bin/planning_health [--root path] [--stage status|discuss|plan|execute|verify|ship|milestone-start|milestone-close] [--phase N]"
  )

  System.halt(2)
end

root = options[:root] || Path.expand("..", __DIR__)
result = Fablebook.Test.PlanningState.check(root, options[:stage] || "status", options[:phase])
IO.puts(JSON.encode!(result))
System.halt(if result.errors == [], do: 0, else: 1)
