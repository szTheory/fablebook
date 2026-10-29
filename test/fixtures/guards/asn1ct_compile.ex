defmodule Fablebook.GuardFixture.Asn1ctCompile do
  def run(spec_file), do: :asn1ct.compile(spec_file)
end
