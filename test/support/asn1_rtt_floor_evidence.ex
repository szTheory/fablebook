defmodule Fablebook.Test.Asn1RttFloorEvidence do
  @moduledoc false

  @rtt_source {"asn1/src/asn1ct_rtt.erl", 134_820,
               "828cdca9f7ac0d4e6d867d712b0e991c94fa46665e17e360196aa39c89305d9d"}
  @caller_source {"asn1/src/asn1ct_func.erl", 4_347,
                  "5487ba870e7c265cd7fe41761f1c5c528385d164faa07df15858fe48e2d21ebf"}

  def record do
    %{
      lane: "floor",
      original_id: "EX-107",
      method: :source_only,
      exact_sources: [@caller_source, @rtt_source],
      selected_function_evidence: [
        assert_defined_evidence(),
        code_evidence(),
        dependencies_evidence()
      ],
      rtt_literal_body: %{
        source: "asn1/src/asn1ct_rtt.erl",
        lines: 533..1038,
        bytes: 112_546,
        sha256: "752eb66bd4f94bca54bb50158b13fce7a835e0b7f047ac0db00fe990a03b272d",
        row_count: 250,
        method: :anchored_byte_grammar
      }
    }
  end

  def selected_mfas,
    do: [
      {:asn1ct_rtt, :assert_defined, 1},
      {:asn1ct_rtt, :code, 0},
      {:asn1ct_rtt, :dependencies, 1}
    ]

  def evidence_for(record, mfa) do
    Enum.find(record.selected_function_evidence, &(&1.mfa == mfa))
  end

  def assert_defined_evidence do
    %{
      mfa: {:asn1ct_rtt, :assert_defined, 1},
      disposition: :static_existing_mfa_membership_check,
      target_span: 17..120,
      caller_path: [
        {"asn1/src/asn1ct_func.erl:44", "need({binary,_,_}) ->"},
        {"asn1/src/asn1ct_func.erl:46", "need({erlang,_,_}) ->"},
        {"asn1/src/asn1ct_func.erl:48", "need(MFA) ->"},
        {"asn1/src/asn1ct_func.erl:49", "    asn1ct_rtt:assert_defined(MFA),"},
        {"asn1/src/asn1ct_func.erl:50", "    cast({need,MFA})."}
      ],
      finding:
        "The floor source enumerates fixed existing MFA clauses; the direct caller bypasses only binary and erlang, then checks the already formed MFA before queuing it. This is static evidence only; runtime behavior, dynamic callers, native internals, and SEC-01 remain unproven."
    }
  end

  def code_evidence do
    %{
      mfa: {:asn1ct_rtt, :code, 0},
      disposition: :static_literal_code_table,
      target_span: 533..1038,
      caller_path: [
        {"asn1/src/asn1ct_func.erl:59", "generate(Fd) ->"},
        {"asn1/src/asn1ct_func.erl:64",
         "    Code = sofs:relation(asn1ct_rtt:code(), [{mfa,code}]),"}
      ],
      finding:
        "The floor source returns a fixed generated-code table consumed by generate/1. The complete table is checked only as bytes against a bounded grammar; its contents are not parsed or evaluated. Runtime behavior, dynamic callers, native internals, and SEC-01 remain unproven."
    }
  end

  def dependencies_evidence do
    %{
      mfa: {:asn1ct_rtt, :dependencies, 1},
      disposition: :static_dependency_lookup,
      target_span: 122..531,
      caller_path: [
        {"asn1/src/asn1ct_func.erl:90", "handle_cast({need,MFA}, #st{used=Used0}=St) ->"},
        {"asn1/src/asn1ct_func.erl:93",
         "\t    Used = pull_in_deps(gb_sets:singleton(MFA), Used0),"},
        {"asn1/src/asn1ct_func.erl:125", "pull_in_deps(Ws0, Used0) ->"},
        {"asn1/src/asn1ct_func.erl:132", "\t    Needs = asn1ct_rtt:dependencies(MFA),"},
        {"asn1/src/asn1ct_func.erl:133", "\t    Ws = update_worklist(Needs, Used, Ws1),"}
      ],
      finding:
        "The floor source maps fixed MFA patterns to dependency lists and ends with a catch-all empty list. The direct caller path processes those lists in the static pull_in_deps/2 traversal. Runtime behavior, dynamic callers, native internals, and SEC-01 remain unproven."
    }
  end
end
