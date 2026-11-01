# Fablebook

Fablebook is a Storybook-style workbench for Phoenix LiveView. This release reserves the name on Hex; the workbench itself is unreleased. Installing it today gives you one dev-only route that confirms the mount works.

## Mounting

Mount Fablebook inside the `dev_routes` block that `phx.new` generates in your router:

```elixir
if Application.compile_env(:my_app, :dev_routes) do
  import Fablebook.Router

  scope "/dev" do
    pipe_through :browser

    fablebook "/fablebook", MyAppWeb.Storybook
  end
end
```

## Troubleshooting

### Fablebook cannot be mounted in a prod build

Your router mounts Fablebook somewhere a `MIX_ENV=prod` build can reach, so the build fails. Move the `fablebook` call inside the `if Application.compile_env(:my_app, :dev_routes)` block, as shown in [Mounting](#mounting). The error message names your app and shows the exact block to use.

The guard runs when the router compiles. A deploy built with `MIX_ENV=dev` cannot be caught at compile time, the same as with LiveDashboard. Build releases with `MIX_ENV=prod`.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for the pinned Elixir lanes and local test commands.
