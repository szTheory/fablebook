defmodule GuardHostWeb.UnguardedRouter do
  use Phoenix.Router, helpers: false
  import Fablebook.Router

  fablebook "/fablebook", GuardHostWeb.Storybook
end
