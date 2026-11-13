defmodule Fablebook.Test.Asn1RttCoreEvidence do
  @moduledoc false

  @rtt_identity %{
    lane: "core",
    path: "asn1/src/asn1ct_rtt.erl",
    bytes: 135_654,
    sha256: "dbdbad10a9af2d46dd617315ef63e226f8425de0ad64a3446058200980d67374"
  }

  @caller_identity %{
    lane: "core",
    path: "asn1/src/asn1ct_func.erl",
    bytes: 4_465,
    sha256: "da8b3b3e951120b1cdbd0622b72d698bd3103c92341d42ba4c6556388818e753"
  }

  @entries [
    %{
      mfa: {:asn1ct_rtt, :assert_defined, 1},
      source: %{
        identity: @rtt_identity,
        citation: "asn1/src/asn1ct_rtt.erl:17",
        first_line: 17,
        last_line: 120,
        span_sha256: "7987a2f35a6e22363efb55fb5df65084046b47fa7a574d1107e66443838a2066"
      },
      caller: %{
        identity: @caller_identity,
        path: [{:asn1ct_func, :need, 1}],
        spans: [
          %{
            citation: "asn1/src/asn1ct_func.erl:48",
            first_line: 48,
            last_line: 54,
            span_sha256: "04570a05b813bcc8d28cdcd9524c214018b2df0e26ff8a7d13ba24f1602f3597"
          }
        ]
      },
      disposition:
        "need/1 exempts only fixed binary and erlang modules, then checks every other already-formed MFA against the fixed source table before sending the fixed need message; this is a static lookup path with no atom construction.",
      control: %{
        guard: "asn1ct_rtt:assert_defined(",
        positive_span: 0,
        negative_citation: "asn1/src/asn1ct_func.erl:69"
      }
    },
    %{
      mfa: {:asn1ct_rtt, :code, 0},
      source: %{
        identity: @rtt_identity,
        citation: "asn1/src/asn1ct_rtt.erl:541",
        first_line: 541,
        last_line: 1055,
        span_sha256: "62884bcb40fdb31730673e9afe79074661f922b7d88a79c05a726c813d3fd11b"
      },
      caller: %{
        identity: @caller_identity,
        path: [{:asn1ct_func, :generate, 1}],
        spans: [
          %{
            citation: "asn1/src/asn1ct_func.erl:64",
            first_line: 64,
            last_line: 72,
            span_sha256: "5bee77ef54293203657864386fe9d09eccb11d1e3a88fe2a54c29e93aabdef22"
          }
        ]
      },
      disposition:
        "generate/1 selects fixed literal rows keyed by already-used MFAs and writes their source bytes to a descriptor; the returned text is not parsed or executed by this evidence path.",
      control: %{
        guard: "asn1ct_rtt:code(",
        positive_span: 0,
        negative_citation: "asn1/src/asn1ct_func.erl:137"
      },
      literal_table: %{first_line: 542, row_count: 258}
    },
    %{
      mfa: {:asn1ct_rtt, :dependencies, 1},
      source: %{
        identity: @rtt_identity,
        citation: "asn1/src/asn1ct_rtt.erl:122",
        first_line: 122,
        last_line: 539,
        span_sha256: "8f9e42a34376c19f7a95fb2b1dcc45359c5289bb6e95313bbc9995cc1c0ba463"
      },
      caller: %{
        identity: @caller_identity,
        path: [{:asn1ct_func, :handle_cast, 2}, {:asn1ct_func, :pull_in_deps, 2}],
        spans: [
          %{
            citation: "asn1/src/asn1ct_func.erl:95",
            first_line: 95,
            last_line: 98,
            span_sha256: "eac569bffd76179c3517449fecc6151a57ca4855e4613389cf1447c02f2d37c1"
          },
          %{
            citation: "asn1/src/asn1ct_func.erl:130",
            first_line: 130,
            last_line: 138,
            span_sha256: "4a8c105eb02b8ac288b0804389eb4751d1136b7caba8eb017550e13eac84ab8a"
          }
        ]
      },
      disposition:
        "handle_cast/2 expands a fixed dependency worklist through pull_in_deps/2 and the literal table; it adds existing MFA terms to a set and does not create atoms from input.",
      control: %{
        guard: "asn1ct_rtt:dependencies(",
        positive_span: 1,
        negative_citation: "asn1/src/asn1ct_func.erl:69"
      }
    }
  ]

  def entries, do: @entries

  def guard_matches?(entry, candidate) when is_binary(candidate) do
    String.contains?(candidate, entry.control.guard)
  end
end
