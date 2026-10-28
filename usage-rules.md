# Fablebook usage rules

- Fablebook is unreleased. This version reserves the name and mounts one placeholder route.
- Mount Fablebook only inside the router's `if Application.compile_env(:my_app, :dev_routes)` block. A mount that a prod build can reach fails to compile.
- Call `fablebook/2` only inside a Phoenix router, after `import Fablebook.Router`. It takes a path and a Book module, and no options.
- Never call the router macro from controllers, LiveViews or other modules.
