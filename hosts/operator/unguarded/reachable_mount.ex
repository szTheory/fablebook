defmodule OperatorHost.Unguarded.ReachableMount do
  use Phoenix.Router

  import Fablebook.Router

  fablebook "/fablebook", OperatorHost.Book
end
