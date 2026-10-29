defmodule GuardHostWeb.Router do
  use Phoenix.Router, helpers: false

  get "/", GuardHost.Ok, :index

  if Application.compile_env(:guard_host, :dev_routes) do
    scope "/dev" do
      import Fablebook.Router

      fablebook "/fablebook", GuardHostWeb.Storybook
    end
  end
end
