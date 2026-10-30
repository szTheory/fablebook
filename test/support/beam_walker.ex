defmodule Fablebook.Test.BeamWalker do
  @moduledoc false

  def scan(beam_path) do
    path = to_charlist(beam_path)

    case :beam_lib.chunks(path, [:debug_info]) do
      {:ok, {_module, [debug_info: {:debug_info_v1, _backend, :none}]}} ->
        {:error, :no_debug_info}

      {:ok, {module, [debug_info: {:debug_info_v1, backend, data}]}} ->
        scan_debug_info(path, module, backend, data)

      {:error, :beam_lib, {:missing_chunk, _, _}} ->
        {:error, :no_debug_info}

      {:error, :beam_lib, reason} ->
        {:error, reason}
    end
  end

  defp scan_debug_info(path, module, backend, data) do
    with {:ok, forms} <- backend.debug_info(:erlang_v1, module, data, []) do
      {:ok, {^module, [imports: imports, compile_info: info]}} =
        :beam_lib.chunks(path, [:imports, :compile_info])

      code = function_code(forms)
      function_mfas = for {:function, _, name, arity, _} <- code, do: {module, name, arity}
      edges = Enum.flat_map(code, &function_edges(module, &1))
      xref_edges = xref_edges(module, forms)

      {:ok,
       %{
         module: module,
         source: to_string(info[:source]),
         atoms: atoms(forms, MapSet.new()),
         mfas: imports,
         function_mfas: function_mfas,
         function_count: length(function_mfas),
         function_bytes: :erlang.external_size(code),
         edges: edges,
         xref_edges: xref_edges,
         pairs: pairs(code, MapSet.new()),
         literals: literals(code, MapSet.new())
       }}
    end
  end

  def xref_edges(module, forms) when is_atom(module) and is_list(forms) do
    forms =
      forms
      |> :epp.interpret_file_attribute()
      |> :erl_expand_records.module([])
      |> :erl_internal.add_predefined_functions()

    abstract = Enum.any?(forms, &abstract_attribute?/1)
    defined = defined_functions(module, forms, abstract)

    forms
    |> Enum.flat_map(fn
      {:function, _anno, :module_info, arity, _clauses} when arity in [0, 1] ->
        []

      {:function, anno, :behaviour_info, 1, _clauses} when anno == 0 ->
        []

      {:function, _anno, name, arity, clauses} ->
        caller = adjust_arity(module, name, arity, abstract)

        state = %{
          module: module,
          caller: caller,
          abstract: abstract,
          defined: defined,
          funvars: MapSet.new(),
          matches: %{},
          edges: MapSet.new()
        }

        clauses
        |> Enum.reduce(state, fn clause, accumulated ->
          scoped = %{accumulated | funvars: MapSet.new(), matches: %{}}
          scanned = scan_clause(clause, scoped)
          %{accumulated | edges: MapSet.union(accumulated.edges, scanned.edges)}
        end)
        |> Map.fetch!(:edges)
        |> MapSet.to_list()

      _form ->
        []
    end)
    |> Enum.uniq()
    |> Enum.sort()
  end

  def xref_edges(beam_path) do
    path = to_charlist(beam_path)

    with {:ok, {module, [debug_info: {:debug_info_v1, backend, data}]}} when data != :none <-
           :beam_lib.chunks(path, [:debug_info]),
         {:ok, forms} <- backend.debug_info(:erlang_v1, module, data, []) do
      {:ok, xref_edges(module, forms)}
    else
      _result -> {:error, :no_debug_info}
    end
  end

  defp abstract_attribute?({:attribute, _anno, :abstract, true}), do: true

  defp abstract_attribute?({:attribute, _anno, :abstract, values}) when is_list(values),
    do: true in values

  defp abstract_attribute?(_form), do: false

  defp adjust_arity(module, function, arity, true)
       when function not in [:module_info, :behaviour_info, :new, :instance],
       do: {module, function, arity - 1}

  defp adjust_arity(module, function, arity, _abstract), do: {module, function, arity}

  defp defined_functions(module, forms, abstract) do
    functions =
      forms
      |> Enum.flat_map(fn
        {:function, _anno, :module_info, arity, _clauses} when arity in [0, 1] ->
          []

        {:function, 0, :behaviour_info, 1, _clauses} ->
          []

        {:function, _anno, function, arity, _clauses} ->
          [adjust_arity(module, function, arity, abstract)]

        _form ->
          []
      end)

    MapSet.new(functions ++ [{module, :module_info, 0}, {module, :module_info, 1}])
  end

  defp scan_clause({:clause, _anno, _head, guards, body}, state),
    do: scan_expr(body, scan_expr(guards, state))

  defp scan_clause(_clause, state), do: state

  defp scan_clauses(clauses, state) do
    Enum.reduce(clauses, state, fn clause, accumulated ->
      scoped = %{accumulated | funvars: state.funvars, matches: state.matches}
      scanned = scan_clause(clause, scoped)
      %{accumulated | edges: MapSet.union(accumulated.edges, scanned.edges)}
    end)
  end

  defp scan_expr({:case, _anno, expression, clauses}, state),
    do: scan_clauses(clauses, scan_expr(expression, state))

  defp scan_expr({:if, _anno, clauses}, state), do: scan_clauses(clauses, state)
  defp scan_expr({:receive, _anno, clauses}, state), do: scan_clauses(clauses, state)

  defp scan_expr({:receive, _anno, clauses, timeout, after_expressions}, state) do
    state = scan_expr(timeout, state)
    state = scan_expr(after_expressions, state)
    scan_clauses(clauses, state)
  end

  defp scan_expr({:try, _anno, expressions, success, catch_clauses, after_expressions}, state) do
    state = scan_expr(expressions, state)
    state = scan_clauses(success, state)
    state = scan_clauses(catch_clauses, state)
    scan_expr(after_expressions, state)
  end

  defp scan_expr({:clause, _, _, _, _} = clause, state), do: scan_clause(clause, state)

  defp scan_expr({:fun, _anno, {:clauses, clauses}}, state),
    do: scan_clauses(clauses, state)

  defp scan_expr({:fun, _anno, {:clauses, clauses}, _extra}, state),
    do: scan_clauses(clauses, state)

  defp scan_expr({:named_fun, _anno, name, clauses}, state),
    do: scan_clauses(clauses, %{state | funvars: MapSet.put(state.funvars, name)})

  defp scan_expr({:call, _anno, {:atom, _, function}, args}, state) when is_atom(function) do
    state = add_local_xref_edge(state, {state.module, function, length(args)})
    scan_expr(args, state)
  end

  defp scan_expr(
         {:call, anno, {:remote, _remote_anno, {:atom, _, module}, {:atom, _, function}}, args},
         state
       )
       when is_atom(module) and is_atom(function) do
    external_call(module, function, args, anno, false, state)
  end

  defp scan_expr({:call, anno, {:remote, _, module_expr, function_expr}, args}, state) do
    list = list_term(args, anno)
    external_call(:erlang, :apply, [module_expr, function_expr, list], anno, true, state)
  end

  defp scan_expr({:call, anno, function_expr, args}, state) do
    external_call(:erlang, :apply, [function_expr, list_term(args, anno)], anno, true, state)
  end

  defp scan_expr({:match, _anno, {:var, _, variable}, expression}, state) do
    state =
      case expression do
        {:fun, _, {:clauses, _clauses}} ->
          %{state | funvars: MapSet.put(state.funvars, variable)}

        {:fun, _, {:clauses, _clauses}, _extra} ->
          %{state | funvars: MapSet.put(state.funvars, variable)}

        {:named_fun, _, _, _} ->
          %{state | funvars: MapSet.put(state.funvars, variable)}

        _ ->
          state
      end

    scan_expr(expression, %{state | matches: Map.put(state.matches, variable, expression)})
  end

  defp scan_expr({:op, _anno, operator, left, right}, state) when operator in [:orelse, :andalso],
    do: scan_expr([left, right], state)

  defp scan_expr({:op, anno, operator, left, right}, state),
    do: external_call(:erlang, operator, [left, right], anno, false, state)

  defp scan_expr({:op, anno, operator, operand}, state),
    do: external_call(:erlang, operator, [operand], anno, false, state)

  defp scan_expr(
         {:fun, anno,
          {:function, {:atom, _, module}, {:atom, _, function}, {:integer, _, arity}}},
         state
       ),
       do: external_call(module, function, dummy_args(arity, anno), anno, false, state)

  defp scan_expr(
         {:fun, anno, {:function, module_expr, function_expr, {:integer, _, arity}}},
         state
       ),
       do:
         external_call(
           :erlang,
           :apply,
           [module_expr, function_expr, list_term(dummy_args(arity, anno), anno)],
           anno,
           true,
           state
         )

  defp scan_expr({:fun, anno, {:function, module_expr, function_expr, _arity}}, state),
    do:
      external_call(
        :erlang,
        :apply,
        [module_expr, function_expr, {:var, anno, :_}],
        anno,
        true,
        state
      )

  defp scan_expr({:fun, _anno, {:function, function, arity}}, state)
       when is_atom(function) and is_integer(arity),
       do: add_local_xref_edge(state, {state.module, function, arity})

  defp scan_expr(term, state) when is_tuple(term),
    do: scan_expr(Tuple.to_list(term), state)

  defp scan_expr([head | tail], state), do: scan_expr(tail, scan_expr(head, state))
  defp scan_expr(_term, state), do: state

  defp external_call(module, function, args, anno, dynamic, state) do
    arity = length(args)
    kind = funfun_kind(module, function, arity)
    type_test? = module == :erlang and :erl_internal.type_test(function, arity)

    state =
      if dynamic or type_test? do
        state
      else
        add_xref_edge(state, {module, function, arity})
      end

    dispatch_funfun(kind, args, anno, state)
  end

  defp dispatch_funfun(:apply2, [{:tuple, _, [module, function]}, args_term] = args, anno, state),
    do: eval_apply_args(module, function, args_term, anno, state, args, [])

  defp dispatch_funfun(1, [{:tuple, _, [module, function]} | rest] = args, anno, state),
    do: eval_apply_args(module, function, list_term([], anno), anno, state, args, rest)

  defp dispatch_funfun(1, args, anno, state), do: check_funarg(1, args, anno, state)

  defp dispatch_funfun(2, [node, {:tuple, _, [module, function]} | rest] = args, anno, state),
    do: eval_apply_args(module, function, list_term([], anno), anno, state, args, [node | rest])

  defp dispatch_funfun(2, args, anno, state), do: check_funarg(2, args, anno, state)

  defp dispatch_funfun(3, [module, function, args_term | rest] = args, anno, state),
    do: eval_apply_args(module, function, args_term, anno, state, args, rest)

  defp dispatch_funfun(4, [node, module, function, args_term | rest] = args, anno, state),
    do: eval_apply_args(module, function, args_term, anno, state, args, [node | rest])

  defp dispatch_funfun(:debug4, [module, function, args_term, _options] = args, anno, state),
    do: eval_apply_args(module, function, args_term, anno, state, args, [])

  defp dispatch_funfun(:apply2, args, anno, state), do: check_funarg(:apply2, args, anno, state)
  defp dispatch_funfun(_kind, args, _anno, state), do: scan_expr(args, state)

  defp funfun_kind(:erlang, :apply, 2), do: :apply2
  defp funfun_kind(:erlang, :apply, 3), do: 3
  defp funfun_kind(:erlang, :spawn, 1), do: 1
  defp funfun_kind(:erlang, :spawn, 2), do: 2
  defp funfun_kind(:erlang, :spawn, 3), do: 3
  defp funfun_kind(:erlang, :spawn, 4), do: 4
  defp funfun_kind(:erlang, :spawn_link, 1), do: 1
  defp funfun_kind(:erlang, :spawn_link, 2), do: 2
  defp funfun_kind(:erlang, :spawn_link, 3), do: 3
  defp funfun_kind(:erlang, :spawn_link, 4), do: 4
  defp funfun_kind(:erlang, :spawn_opt, 2), do: 1
  defp funfun_kind(:erlang, :spawn_opt, 3), do: 2
  defp funfun_kind(:erlang, :spawn_opt, 4), do: 3
  defp funfun_kind(:erlang, :spawn_opt, 5), do: 4
  defp funfun_kind(:erts_debug, :apply, 4), do: :debug4
  defp funfun_kind(_module, _function, _arity), do: false

  defp eval_apply_args(module_expr, function_expr, args_term, anno, state, original_args, extra) do
    {simple?, module, function} = module_function(module_expr, function_expr)

    case term_to_list(args_term, state, []) do
      :unknown ->
        state = add_unresolved(state, module, function, -1)
        scan_expr(original_args, state)

      args when not simple? ->
        state = add_unresolved(state, module, function, length(args))
        scan_expr(original_args, state)

      args ->
        state = scan_expr(extra, state)
        external_call(module, function, args, anno, false, state)
    end
  end

  defp module_function({:atom, _, module}, {:atom, _, function}), do: {true, module, function}
  defp module_function({:atom, _, module}, _function), do: {false, module, :"$F_EXPR"}
  defp module_function(_module, {:atom, _, function}), do: {false, :"$M_EXPR", function}
  defp module_function(_module, _function), do: {false, :"$M_EXPR", :"$F_EXPR"}

  defp check_funarg(kind, args, _anno, state) do
    {fun_arg, args_term} = fun_argument(kind, args)

    if known_fun?(fun_arg, state) do
      scan_expr(args, state)
    else
      arity = unresolved_fun_arity(kind, args_term, state)
      state = add_unresolved(state, :"$M_EXPR", :"$F_EXPR", arity)
      scan_expr(args, state)
    end
  end

  defp unresolved_fun_arity(kind, _args_term, _state) when kind in [1, 2], do: 0

  defp unresolved_fun_arity(_kind, args_term, state) do
    case term_to_list(args_term, state, []) do
      :unknown -> -1
      terms -> length(terms)
    end
  end

  defp fun_argument(1, [fun_arg | _rest]), do: {fun_arg, nil}
  defp fun_argument(2, [_node, fun_arg | _rest]), do: {fun_arg, nil}
  defp fun_argument(:apply2, [fun_arg, args]), do: {fun_arg, args}
  defp fun_argument(_kind, _args), do: {nil, nil}

  defp known_fun?({:fun, _, _}, _state), do: true
  defp known_fun?({:fun, _, _, _}, _state), do: true
  defp known_fun?({:named_fun, _, _, _}, _state), do: true

  defp known_fun?({:var, _, variable}, state),
    do: MapSet.member?(state.funvars, variable)

  defp known_fun?(_other, _state), do: false

  defp add_unresolved(state, module, function, arity),
    do: add_xref_edge(state, {module, function, arity})

  defp add_local_xref_edge(state, {module, function, arity} = mfa) do
    if MapSet.member?(state.defined, mfa),
      do: add_xref_edge(state, {module, function, arity}),
      else: state
  end

  defp add_xref_edge(state, {module, function, arity})
       when is_atom(module) and is_atom(function) do
    mfa = adjust_arity(module, function, arity, module == state.module and state.abstract)
    %{state | edges: MapSet.put(state.edges, {state.caller, mfa})}
  end

  defp term_to_list({:cons, _anno, head, tail}, state, accumulated),
    do: term_to_list(tail, state, [head | accumulated])

  defp term_to_list({nil, _anno}, _state, accumulated), do: Enum.reverse(accumulated)

  defp term_to_list({:var, _, variable}, state, accumulated) do
    case Map.fetch(state.matches, variable) do
      {:ok, expression} -> term_to_list(expression, state, accumulated)
      :error -> :unknown
    end
  end

  defp term_to_list(_term, _state, _accumulated), do: :unknown

  defp list_term(expressions, anno),
    do:
      Enum.reduce(Enum.reverse(expressions), {nil, anno}, fn expr, tail ->
        {:cons, anno, expr, tail}
      end)

  defp dummy_args(arity, anno) when is_integer(arity) and arity >= 0,
    do: List.duplicate({:atom, anno, :xref_dummy}, arity)

  defp function_code(forms),
    do: for({:function, _, name, arity, _} = f <- forms, {name, arity} != {:__info__, 1}, do: f)

  defp function_edges(module, {:function, _, name, arity, clauses}) do
    caller = {module, name, arity}
    for callee <- callees(module, clauses, []) |> Enum.uniq(), do: {caller, callee}
  end

  defp callees(module, [{:atom, _, m}, {:atom, _, f} = next | rest], acc),
    do: callees(module, [next | rest], [{m, f} | acc])

  defp callees(module, [head | tail], acc), do: callees(module, tail, callees(module, head, acc))

  defp callees(module, {:call, _, {:atom, _, function}, args}, acc),
    do: callees(module, args, [{module, function} | acc])

  defp callees(module, {:fun, _, {:function, function_name, arity}}, acc)
       when is_atom(function_name) and is_integer(arity),
       do: [{module, function_name} | acc]

  defp callees(module, tuple, acc) when is_tuple(tuple),
    do: callees(module, Tuple.to_list(tuple), acc)

  defp callees(_module, _other, acc), do: acc

  defp atoms(term, acc) when is_atom(term), do: MapSet.put(acc, term)
  defp atoms(term, acc) when is_tuple(term), do: atoms(Tuple.to_list(term), acc)
  defp atoms(term, acc) when is_list(term), do: Enum.reduce(term, acc, &atoms/2)

  defp atoms(term, acc) when is_map(term),
    do: Enum.reduce(term, acc, fn {k, v}, acc -> atoms(v, atoms(k, acc)) end)

  defp atoms(_term, acc), do: acc

  defp pairs([{:atom, _, m}, {:atom, _, f} = next | rest], acc),
    do: pairs([next | rest], MapSet.put(acc, {m, f}))

  defp pairs([head | tail], acc), do: pairs(tail, pairs(head, acc))
  defp pairs(term, acc) when is_tuple(term), do: pairs(Tuple.to_list(term), acc)
  defp pairs(_term, acc), do: acc

  defp literals({:atom, _, atom}, acc), do: MapSet.put(acc, atom)

  defp literals({:call, _, {:remote, _, module, {:atom, _, _}}, args}, acc),
    do: literals(args, literals(module, acc))

  defp literals({:call, _, {:atom, _, _}, args}, acc), do: literals(args, acc)

  defp literals({:fun, _, {:function, module, {:atom, _, _}, arity}}, acc),
    do: literals(arity, literals(module, acc))

  defp literals(term, acc) when is_tuple(term), do: literals(Tuple.to_list(term), acc)
  defp literals(term, acc) when is_list(term), do: Enum.reduce(term, acc, &literals/2)
  defp literals(_term, acc), do: acc
end
