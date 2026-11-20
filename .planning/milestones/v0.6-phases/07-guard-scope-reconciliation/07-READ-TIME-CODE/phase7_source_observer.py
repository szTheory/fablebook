"""Conservative, in-memory source span observer for Elixir and Erlang.

This module never reads files or executes parsed code. Callers supply source
bytes that they have already obtained under their own read policy.

The parser intentionally supports a bounded subset of each language. It
returns no partial result: unsupported or structurally incomplete source raises
ObserverError. Reference locations are statically recognizable, parenthesized
calls only; dynamic dispatch, captures, macro expansion, imported/aliased
resolution, and calls inside quoted strings are outside the observation model.
"""

from __future__ import annotations

from bisect import bisect_right
from dataclasses import dataclass
import re
from typing import Iterable, Sequence


MAX_SOURCE_BYTES = 2 * 1024 * 1024
MAX_TOKENS = 300_000
MAX_SELECTORS = 64
MAX_REFERENCES_PER_SELECTOR = 100


class ObserverError(ValueError):
    """The requested source observation cannot be made completely and safely."""


@dataclass(frozen=True)
class _Token:
    value: str
    kind: str
    start: int  # character offsets in decoded source
    end: int


@dataclass(frozen=True)
class _Source:
    data: bytes
    text: str
    byte_at: tuple[int, ...]
    line_starts: tuple[int, ...]

    @classmethod
    def from_bytes(cls, data: bytes) -> "_Source":
        if not isinstance(data, bytes):
            raise ObserverError("source must be bytes")
        if len(data) > MAX_SOURCE_BYTES:
            raise ObserverError(f"source exceeds {MAX_SOURCE_BYTES} byte limit")
        try:
            text = data.decode("utf-8", errors="strict")
        except UnicodeDecodeError as exc:
            raise ObserverError("source is not strict UTF-8") from exc
        if "\x00" in text:
            raise ObserverError("NUL bytes are unsupported")
        byte_at = [0]
        for char in text:
            byte_at.append(byte_at[-1] + len(char.encode("utf-8")))
        line_starts = [0]
        line_starts.extend(i + 1 for i, char in enumerate(text) if char == "\n")
        return cls(data, text, tuple(byte_at), tuple(line_starts))

    def line(self, char_offset: int) -> int:
        return bisect_right(self.line_starts, char_offset)

    def record(self, start: int, end: int) -> dict[str, object]:
        if start < 0 or end <= start or end > len(self.text):
            raise ObserverError("internal span bounds are invalid")
        byte_start = self.byte_at[start]
        byte_end = self.byte_at[end]
        return {
            "start_byte": byte_start,
            "end_byte": byte_end,
            "start_line": self.line(start),
            "end_line": self.line(end - 1),
            "text": self.data[byte_start:byte_end].decode("utf-8", errors="strict"),
        }


_ELIXIR_MULTI = ("\\\\", "->", "=>", "::", "<-", "|>", "&&", "||", "==", "!=", "<=", ">=", "++", "--", "<>", "..", "<<", ">>")
_ERLANG_MULTI = ("->", "<-", "=>", ":=", "==", "/=", "=<", ">=", "++", "--", "<<", ">>", "||", "..")


def _quoted_end(text: str, start: int, quote: str, triple: bool = False) -> int:
    marker = quote * (3 if triple else 1)
    i = start + len(marker)
    while i < len(text):
        if text[i] == "\\":
            i += 2
            continue
        if text.startswith(marker, i):
            return i + len(marker)
        i += 1
    raise ObserverError("unterminated quoted literal")


def _sigil_end(text: str, start: int) -> int:
    # Bounded support for Elixir sigils with paired or unpaired delimiters.
    i = start + 1
    if i < len(text) and text[i].isalpha():
        i += 1
    if i >= len(text):
        raise ObserverError("incomplete Elixir sigil")
    delim = text[i]
    if delim.isspace() or delim.isalnum():
        raise ObserverError("unsupported Elixir sigil form")
    triples = delim in "\"'" and text.startswith(delim * 3, i)
    opener = delim * (3 if triples else 1)
    closer = {"(": ")", "[": "]", "{": "}", "<": ">"}.get(delim, delim)
    closer *= 3 if triples else 1
    i += len(opener)
    depth = 1
    while i < len(text):
        if text[i] == "\\":
            i += 2
            continue
        if opener != closer and text.startswith(opener, i):
            depth += 1
            i += len(opener)
            continue
        if text.startswith(closer, i):
            depth -= 1
            i += len(closer)
            if depth == 0:
                while i < len(text) and text[i].isalpha():
                    i += 1
                return i
            continue
        i += 1
    raise ObserverError("unterminated Elixir sigil")


def _unquote_simple(raw: str) -> str:
    """Decode the small escape subset used for statically named quoted atoms."""
    out: list[str] = []
    i = 0
    escapes = {"n": "\n", "r": "\r", "t": "\t", "b": "\b", "f": "\f", "v": "\v", "\\": "\\", "'": "'", '"': '"'}
    while i < len(raw):
        if raw[i] != "\\":
            out.append(raw[i])
            i += 1
            continue
        if i + 1 >= len(raw):
            raise ObserverError("incomplete quoted-atom escape")
        nxt = raw[i + 1]
        if nxt not in escapes:
            raise ObserverError("unsupported quoted-atom escape")
        out.append(escapes[nxt])
        i += 2
    return "".join(out)


def _lex(source: _Source, language: str) -> list[_Token]:
    text = source.text
    multi = _ELIXIR_MULTI if language == "elixir" else _ERLANG_MULTI
    out: list[_Token] = []
    i = 0
    while i < len(text):
        ch = text[i]
        if ch.isspace():
            i += 1
            continue
        if (language == "elixir" and ch == "#") or (language == "erlang" and ch == "%"):
            nl = text.find("\n", i)
            i = len(text) if nl < 0 else nl + 1
            continue
        if language == "elixir" and ch == "~":
            i = _sigil_end(text, i)
            continue
        if ch in "\"'":
            triple = text.startswith(ch * 3, i)
            end = _quoted_end(text, i, ch, triple)
            if language == "erlang" and ch == "'":
                width = 3 if triple else 1
                raw = text[i + width : end - width]
                out.append(_Token(_unquote_simple(raw), "qatom", i, end))
            # Strings, Elixir charlists, and quoted values are opaque to tokens.
            i = end
            continue
        if language == "erlang" and ch == "$":
            i += 1
            if i >= len(text):
                raise ObserverError("incomplete Erlang character literal")
            if text[i] == "\\":
                i += 2
            else:
                i += 1
            continue
        if ch.isalpha() or ch == "_":
            start = i
            i += 1
            while i < len(text) and (text[i].isalnum() or text[i] == "_"):
                i += 1
            if language == "elixir" and i < len(text) and text[i] in "?!":
                i += 1
            out.append(_Token(text[start:i], "id", start, i))
        elif ch.isdigit():
            start = i
            i += 1
            while i < len(text) and (text[i].isalnum() or text[i] == "_"):
                i += 1
            # Keep ordinary decimal floats in one token so their dot is not
            # mistaken for an Erlang form terminator.
            if i < len(text) and text[i] == "." and i + 1 < len(text) and text[i + 1].isdigit():
                i += 1
                while i < len(text) and (text[i].isdigit() or text[i] == "_"):
                    i += 1
            out.append(_Token(text[start:i], "number", start, i))
        else:
            if language == "elixir" and ch == "\\" and i + 1 < len(text) and text[i + 1] == "\\":
                out.append(_Token("\\\\", "op", i, i + 2))
                i += 2
                continue
            found = next((op for op in multi if text.startswith(op, i)), None)
            if found:
                out.append(_Token(found, "op", i, i + len(found)))
                i += len(found)
            else:
                out.append(_Token(ch, "punct", i, i + 1))
                i += 1
        if len(out) > MAX_TOKENS:
            raise ObserverError(f"source exceeds {MAX_TOKENS} token limit")
    return out


def _delimiter_pairs(tokens: Sequence[_Token]) -> dict[int, int]:
    pairs: dict[int, int] = {}
    stack: list[tuple[str, int]] = []
    openers = {"(": ")", "[": "]", "{": "}", "<<": ">>"}
    closers = {v: k for k, v in openers.items()}
    for i, token in enumerate(tokens):
        if token.value in openers:
            stack.append((token.value, i))
        elif token.value in closers:
            if not stack or stack[-1][0] != closers[token.value]:
                raise ObserverError("unbalanced delimiter")
            _, start = stack.pop()
            pairs[start] = i
            pairs[i] = start
    if stack:
        raise ObserverError("incomplete delimiter")
    return pairs


def _block_pairs(tokens: Sequence[_Token], language: str) -> dict[int, int]:
    pairs: dict[int, int] = {}
    stack: list[tuple[int, str]] = []
    for i, token in enumerate(tokens):
        value = token.value
        if language == "elixir":
            atom_word = i > 0 and tokens[i - 1].value == ":"
            keyword_value = (i + 1 < len(tokens) and tokens[i + 1].value == ":"
                             and tokens[i + 1].start == token.end)
            if value == "end":
                if not stack:
                    raise ObserverError("unmatched Elixir end")
                start, _ = stack.pop()
                pairs[start] = i
                pairs[i] = start
            elif (value == "do" and not atom_word and not keyword_value) or value == "fn":
                stack.append((i, value))
        else:
            if value == "end":
                if not stack:
                    raise ObserverError("unmatched Erlang end")
                start, _ = stack.pop()
                pairs[start] = i
                pairs[i] = start
            elif value in {"case", "if", "receive", "try", "begin", "maybe"}:
                stack.append((i, value))
            elif value == "fun":
                # `fun Name/Arity` is a reference; `fun(...)` and `fun Name(...)`
                # are anonymous function expressions that close with `end`.
                next_value = tokens[i + 1].value if i + 1 < len(tokens) else ""
                following = tokens[i + 2].value if i + 2 < len(tokens) else ""
                if next_value == "(" or (next_value not in {"", ":"} and following == "("):
                    stack.append((i, value))
    if stack:
        raise ObserverError("incomplete block expression")
    return pairs


def _arg_count(tokens: Sequence[_Token], opening: int, closing: int, pairs: dict[int, int]) -> int:
    if closing == opening + 1:
        return 0
    count = 1
    i = opening + 1
    while i < closing:
        if i in pairs and pairs[i] > i:
            i = pairs[i] + 1
            continue
        if tokens[i].value == ",":
            count += 1
        i += 1
    return count


def _arg_parts(tokens: Sequence[_Token], opening: int, closing: int, pairs: dict[int, int]) -> list[tuple[int, int]]:
    if closing == opening + 1:
        return []
    parts: list[tuple[int, int]] = []
    start = opening + 1
    i = start
    while i < closing:
        if i in pairs and pairs[i] > i:
            i = pairs[i] + 1
            continue
        if tokens[i].value == ",":
            if start == i:
                raise ObserverError("empty argument in signature")
            parts.append((start, i))
            start = i + 1
        i += 1
    if start >= closing:
        raise ObserverError("trailing comma in signature")
    parts.append((start, closing))
    return parts


def _normal_module(module: str) -> str:
    return module[7:] if module.startswith("Elixir.") else module


def _selector_map(selectors: Iterable[tuple[str, str, int]]) -> list[tuple[str, str, int]]:
    normalized: list[tuple[str, str, int]] = []
    seen: set[tuple[str, str, int]] = set()
    for raw in selectors:
        if not isinstance(raw, tuple) or len(raw) != 3:
            raise ObserverError("each selector must be a (module, function, arity) tuple")
        module, function, arity = raw
        if not isinstance(module, str) or not module or not isinstance(function, str) or not function:
            raise ObserverError("selector module and function must be non-empty strings")
        if not isinstance(arity, int) or isinstance(arity, bool) or arity < 0:
            raise ObserverError("selector arity must be a non-negative integer")
        item = (_normal_module(module), function, arity)
        if item not in seen:
            normalized.append(item)
            seen.add(item)
    if not normalized:
        raise ObserverError("at least one selector is required")
    if len(normalized) > MAX_SELECTORS:
        raise ObserverError(f"selector count exceeds {MAX_SELECTORS} limit")
    return normalized


def _elixir_modules(tokens: Sequence[_Token], blocks: dict[int, int]) -> list[tuple[int, int, str]]:
    modules: list[tuple[int, int, str]] = []
    for i, token in enumerate(tokens):
        if token.value != "defmodule":
            continue
        parent_candidates = [(a, b, name) for a, b, name in modules if a < i < b]
        parent = max(parent_candidates, key=lambda item: item[0])[2] if parent_candidates else ""
        j = i + 1
        names: list[str] = []
        expect_name = True
        while j < len(tokens) and tokens[j].value != "do":
            value = tokens[j].value
            if tokens[j].kind != "id" and value != ".":
                raise ObserverError("unsupported dynamic Elixir module name")
            if expect_name != (value != "."):
                raise ObserverError("malformed Elixir module name")
            names.append(value)
            expect_name = value == "."
            j += 1
        if j >= len(tokens) or j not in blocks or expect_name:
            raise ObserverError("incomplete Elixir module declaration")
        name = "".join(names)
        if name.startswith("Elixir."):
            name = name[7:]
        elif parent and "." not in name:
            name = parent + "." + name
        modules.append((j, blocks[j], name))
    return modules


def _elixir_module_at(index: int, modules: Sequence[tuple[int, int, str]]) -> str | None:
    candidates = [module for module in modules if module[0] < index < module[1]]
    return max(candidates, key=lambda item: item[0])[2] if candidates else None


def _elixir_definition(
    tokens: Sequence[_Token],
    i: int,
    delims: dict[int, int],
    blocks: dict[int, int],
    source: _Source,
) -> tuple[str, int, int, int, int, str]:
    kind = tokens[i].value
    if i + 1 >= len(tokens) or tokens[i + 1].kind != "id":
        raise ObserverError("unsupported dynamic Elixir function name")
    name = tokens[i + 1].value
    cursor = i + 2
    defaults = 0
    if cursor < len(tokens) and tokens[cursor].value == "(":
        close = delims.get(cursor)
        if close is None:
            raise ObserverError("incomplete Elixir function signature")
        parts = _arg_parts(tokens, cursor, close, delims)
        declared_arity = len(parts)
        for start, end in parts:
            if any(tokens[k].value == "\\\\" for k in range(start, end)):
                defaults += 1
        if defaults > declared_arity:
            raise ObserverError("invalid Elixir default-argument count")
        cursor = close + 1
    elif cursor < len(tokens) and tokens[cursor].value in {"do", ","}:
        declared_arity = 0
    else:
        raise ObserverError("unsupported parenthesis-free Elixir signature")

    body_marker = None
    body_is_keyword = False
    j = cursor
    while j < len(tokens):
        if j in delims and delims[j] > j:
            j = delims[j] + 1
            continue
        value = tokens[j].value
        if value == "do" and not (j > 0 and tokens[j - 1].value == ":"):
            body_marker = j
            body_is_keyword = j + 1 < len(tokens) and tokens[j + 1].value == ":"
            break
        # A default declaration head can end immediately after its signature.
        if source.line(tokens[j].start) > source.line(tokens[j - 1].end - 1):
            break
        j += 1

    if body_marker is None:
        # A bodyless declaration is useful evidence for generated default arities.
        # It must end at the signature; guards or arbitrary trailing syntax fail.
        if cursor < len(tokens) and tokens[cursor].value == "(":
            close = delims[cursor]
            if close + 1 == j or close + 1 < len(tokens) and source.line(tokens[close + 1].start) > source.line(tokens[close].end - 1):
                end_char = tokens[close].end
                if defaults == 0:
                    raise ObserverError("bodyless Elixir function declaration has no defaults")
                return name, declared_arity, defaults, tokens[i].start, end_char, "head"
        raise ObserverError("cannot locate complete Elixir function body")

    if body_is_keyword:
        expr = body_marker + 2
        if expr >= len(tokens):
            raise ObserverError("empty one-line Elixir function body")
        start_line = source.line(tokens[expr].start)
        end_index = expr
        while end_index + 1 < len(tokens) and source.line(tokens[end_index + 1].start) == start_line:
            end_index += 1
        # Multiline keyword bodies need a full expression grammar; reject instead
        # of silently clipping the candidate.
        if end_index + 1 < len(tokens) and source.line(tokens[end_index + 1].start) == start_line + 1:
            next_token = tokens[end_index + 1]
            if next_token.value not in {"def", "defp", "defmacro", "defmacrop", "end", "@"}:
                raise ObserverError("multiline `do:` expression is unsupported")
        return name, declared_arity, defaults, tokens[i].start, tokens[end_index].end, "inline"

    if body_marker not in blocks:
        raise ObserverError("incomplete Elixir function block")
    end_token = blocks[body_marker]
    return name, declared_arity, defaults, tokens[i].start, tokens[end_token].end, "block"


def _elixir_qualifier(tokens: Sequence[_Token], index: int) -> str | None:
    if index < 2 or tokens[index - 1].value != ".":
        return None
    parts: list[str] = []
    j = index - 2
    if tokens[j].kind != "id":
        return None
    parts.append(tokens[j].value)
    j -= 1
    while j >= 1 and tokens[j].value == "." and tokens[j - 1].kind == "id":
        parts.append(tokens[j - 1].value)
        j -= 2
    parts.reverse()
    return _normal_module("".join(parts))


def _parse_elixir(source: _Source, selectors: list[tuple[str, str, int]]) -> dict[tuple[str, str, int], dict[str, object]]:
    tokens = _lex(source, "elixir")
    delims = _delimiter_pairs(tokens)
    blocks = _block_pairs(tokens, "elixir")
    modules = _elixir_modules(tokens, blocks)
    selected = set(selectors)
    definitions: dict[tuple[str, str, int], list[dict[str, object]]] = {s: [] for s in selectors}
    def_indices: set[int] = set()
    def_name_indices: set[int] = set()
    definition_spans: dict[int, tuple[int, int]] = {}
    def_kinds = {"def", "defp", "defmacro", "defmacrop"}
    for i, token in enumerate(tokens):
        if token.value not in def_kinds:
            continue
        def_indices.add(i)
        module = _elixir_module_at(i, modules)
        next_name = tokens[i + 1].value if i + 1 < len(tokens) and tokens[i + 1].kind == "id" else None
        if next_name is not None:
            def_name_indices.add(i + 1)
        relevant = module is not None and any(m == module and (next_name == f or next_name is None) for m, f, _ in selected)
        if not relevant:
            continue
        if next_name is None:
            raise ObserverError("selected Elixir module contains a dynamic function definition")
        name, declared, defaults, start, end, span_kind = _elixir_definition(tokens, i, delims, blocks, source)
        definition_spans[i] = (start, end)
        # Elixir macros receive an implicit caller argument in their compiled MFA.
        offset = 1 if token.value in {"defmacro", "defmacrop"} else 0
        low = declared - defaults + offset
        high = declared + offset
        if low < 0:
            raise ObserverError("invalid generated Elixir arity range")
        record = source.record(start, end)
        record["kind"] = span_kind
        for selector in selectors:
            if selector[0] == module and selector[1] == name and low <= selector[2] <= high:
                definitions[selector].append(record)

    result: dict[tuple[str, str, int], dict[str, object]] = {}
    for selector in selectors:
        defs = definitions[selector]
        if not defs:
            raise ObserverError(f"no complete definition found for {selector[0]}.{selector[1]}/{selector[2]}")
        result[selector] = {"definitions": list(defs), "references": []}

    for selector in selectors:
        module, function, arity = selector
        refs: list[dict[str, object]] = []
        for i, token in enumerate(tokens):
            if token.value != function or token.kind != "id" or i in def_indices or i in def_name_indices:
                continue
            if i + 1 >= len(tokens) or tokens[i + 1].value != "(":
                continue
            close = delims.get(i + 1)
            if close is None:
                raise ObserverError("incomplete direct Elixir call")
            call_arity = _arg_count(tokens, i + 1, close, delims)
            if call_arity != arity:
                continue
            qualifier = _elixir_qualifier(tokens, i)
            current_module = _elixir_module_at(i, modules)
            if qualifier == module or (qualifier is None and current_module == module):
                # A token inside a selected definition is still a real call site;
                # only the definition name itself is excluded above.
                ref = source.record(token.start, tokens[close].end)
                ref.pop("end_line", None)
                ref["line"] = source.line(token.start)
                refs.append(ref)
        if len(refs) > MAX_REFERENCES_PER_SELECTOR:
            raise ObserverError(f"reference count exceeds {MAX_REFERENCES_PER_SELECTOR} limit for {module}.{function}/{arity}")
        result[selector]["references"] = refs
    return result


def _erl_period(source: _Source, token: _Token, next_token: _Token | None) -> bool:
    if next_token is None:
        return True
    between = source.text[token.end : next_token.start]
    if between:
        return True
    # Adjacent `record.field` is not a form terminator.
    return False


def _parse_erlang(source: _Source, selectors: list[tuple[str, str, int]]) -> dict[tuple[str, str, int], dict[str, object]]:
    tokens = _lex(source, "erlang")
    delims = _delimiter_pairs(tokens)
    blocks = _block_pairs(tokens, "erlang")
    for i, token in enumerate(tokens[:-1]):
        if token.value == "-" and tokens[i + 1].value in {"ifdef", "ifndef", "if", "elif", "else", "endif"}:
            raise ObserverError("conditional Erlang preprocessing is unsupported")

    forms: list[tuple[int, int, int]] = []  # start, content end, terminating period index
    i = 0
    form_start = 0
    while i < len(tokens):
        if i in delims and delims[i] > i:
            i = delims[i] + 1
            continue
        if i in blocks and blocks[i] > i:
            i = blocks[i] + 1
            continue
        if tokens[i].value == "." and _erl_period(source, tokens[i], tokens[i + 1] if i + 1 < len(tokens) else None):
            forms.append((form_start, i, i))
            form_start = i + 1
        i += 1
    if form_start < len(tokens):
        raise ObserverError("incomplete Erlang form (missing terminating period)")

    module_name: str | None = None
    for start, end, _period in forms:
        if start + 4 < end and tokens[start].value == "-" and tokens[start + 1].value == "module" and tokens[start + 2].value == "(":
            if tokens[start + 3].kind in {"id", "qatom"} and tokens[start + 4].value == ")":
                candidate = tokens[start + 3].value
                if module_name is not None and module_name != candidate:
                    raise ObserverError("multiple Erlang module declarations")
                module_name = candidate
    if module_name is None:
        raise ObserverError("Erlang module identity is missing or unsupported")

    selected = set(selectors)
    definitions: dict[tuple[str, str, int], list[dict[str, object]]] = {s: [] for s in selectors}
    definition_name_indices: set[int] = set()
    clause_spans: list[tuple[int, int]] = []
    for start, end, period in forms:
        if start >= end or tokens[start].kind not in {"id", "qatom"} or start + 1 >= end or tokens[start + 1].value != "(":
            continue
        name = tokens[start].value
        clause_start = start
        arrow_seen = False
        j = start
        clause_ranges: list[tuple[int, int]] = []
        while j < end:
            if j in delims and delims[j] > j:
                j = delims[j] + 1
                continue
            if j in blocks and blocks[j] > j:
                j = blocks[j] + 1
                continue
            value = tokens[j].value
            if value == "->":
                arrow_seen = True
            elif value == ";" and arrow_seen:
                clause_ranges.append((clause_start, j + 1))  # include separator
                clause_start = j + 1
                arrow_seen = False
            j += 1
        if clause_start < end:
            clause_ranges.append((clause_start, period + 1))  # include final period
        for cstart, cend in clause_ranges:
            if cstart >= end or tokens[cstart].kind not in {"id", "qatom"} or cstart + 1 >= end or tokens[cstart + 1].value != "(":
                raise ObserverError("unsupported Erlang function clause layout")
            clause_name = tokens[cstart].value
            opening = cstart + 1
            closing = delims.get(opening)
            if closing is None or closing >= end:
                raise ObserverError("incomplete Erlang function clause arguments")
            arity = _arg_count(tokens, opening, closing, delims)
            if not any(m == module_name and f == clause_name and a == arity for m, f, a in selected):
                continue
            if not any(tokens[k].value == "->" for k in range(closing + 1, cend)):
                raise ObserverError("Erlang function clause has no complete body")
            definition_name_indices.add(cstart)
            start_char = tokens[cstart].start
            end_char = tokens[cend - 1].end
            clause_spans.append((start_char, end_char))
            rec = source.record(start_char, end_char)
            for selector in selectors:
                if selector == (module_name, clause_name, arity):
                    definitions[selector].append(rec)

    for selector in selectors:
        if not definitions[selector]:
            raise ObserverError(f"no complete definition found for {selector[0]}:{selector[1]}/{selector[2]}")

    result: dict[tuple[str, str, int], dict[str, object]] = {
        selector: {"definitions": definitions[selector], "references": []} for selector in selectors
    }
    for selector in selectors:
        module, function, arity = selector
        refs: list[dict[str, object]] = []
        for i, token in enumerate(tokens):
            if token.value != function or token.kind not in {"id", "qatom"} or i in definition_name_indices:
                continue
            if i + 1 >= len(tokens) or tokens[i + 1].value != "(":
                continue
            close = delims.get(i + 1)
            if close is None:
                raise ObserverError("incomplete direct Erlang call")
            if _arg_count(tokens, i + 1, close, delims) != arity:
                continue
            qualifier = None
            if i >= 2 and tokens[i - 1].value == ":" and tokens[i - 2].kind in {"id", "qatom"}:
                qualifier = tokens[i - 2].value
            if qualifier == module or (qualifier is None and module_name == module):
                ref = source.record(token.start, tokens[close].end)
                ref.pop("end_line", None)
                ref["line"] = source.line(token.start)
                refs.append(ref)
        if len(refs) > MAX_REFERENCES_PER_SELECTOR:
            raise ObserverError(f"reference count exceeds {MAX_REFERENCES_PER_SELECTOR} limit for {module}:{function}/{arity}")
        result[selector]["references"] = refs
    return result


def extract_mfa_spans(
    source_bytes: bytes,
    language: str,
    selectors: Iterable[tuple[str, str, int]],
) -> dict[tuple[str, str, int], dict[str, object]]:
    """Extract complete definition spans and bounded direct call locations.

    Definition records contain byte offsets (end exclusive), one-based line
    bounds, exact UTF-8 text, and a `kind` field for Elixir (`block`, `inline`,
    or a default-bearing declaration `head`). Reference records contain the
    same offsets/text plus one-based `line`.

    Supported reference resolution is deliberately narrow: Elixir local calls
    in the selected module and fully qualified calls, and Erlang local calls in
    the declared module or calls qualified by its exact module atom. Aliases,
    imports, captures, dynamic apply, macros, and quoted interpolation are not
    resolved. Any parser ambiguity in selected definitions raises ObserverError.
    """
    normalized = _selector_map(selectors)
    source = _Source.from_bytes(source_bytes)
    if language not in {"elixir", "erlang"}:
        raise ObserverError("language must be 'elixir' or 'erlang'")
    if language == "elixir":
        return _parse_elixir(source, normalized)
    return _parse_erlang(source, normalized)


def _assert_raises(function, *args) -> None:
    try:
        function(*args)
    except ObserverError:
        return
    raise AssertionError("expected ObserverError")


def self_test() -> dict[str, int]:
    """Run synthetic in-memory positive/negative controls; performs no I/O."""
    elixir = b'''defmodule Demo do
  # greet(9, 10) is only a comment
  def greet(name, opts \\\\ [nested: [1, 2]]) do
    text = "not_a_call(1, 2)"
    if opts do
      greet(name)
    else
      :ok
    end
  end

  def greet(name, opts) when is_map(opts) do
    {name, opts}
  end

  def parse?(value, nested) do
    inspect({value, [nested, {1, 2}]})
  end

  def empty!, do: :ok
end
'''
    selectors = [("Demo", "greet", 1), ("Demo", "greet", 2), ("Demo", "parse?", 2), ("Demo", "empty!", 0)]
    got = extract_mfa_spans(elixir, "elixir", selectors)
    assert got[("Demo", "greet", 1)]["definitions"] and "opts" in got[("Demo", "greet", 1)]["definitions"][0]["text"]
    assert len(got[("Demo", "greet", 2)]["definitions"]) == 2
    assert len(got[("Demo", "greet", 1)]["references"]) == 1
    assert "not_a_call" not in str(got[("Demo", "greet", 1)]["references"])
    assert got[("Demo", "parse?", 2)]["definitions"][0]["text"].startswith("def parse?")
    assert got[("Demo", "empty!", 0)]["definitions"][0]["kind"] == "inline"
    header_only = extract_mfa_spans(b"defmodule D do\n  def compile(value), do: value\nend\n", "elixir", [("D", "compile", 1)])
    assert header_only[("D", "compile", 1)]["references"] == []
    namespaced_atom_body = b'''defmodule Phoenix.LiveView.ColocatedAssets do
  def compile do
    :ok
  end
end
'''
    namespaced_result = extract_mfa_spans(
        namespaced_atom_body, "elixir",
        [("Elixir.Phoenix.LiveView.ColocatedAssets", "compile", 0)],
    )
    normalized_selector = ("Phoenix.LiveView.ColocatedAssets", "compile", 0)
    assert namespaced_result[normalized_selector]["definitions"]
    inline_atom = extract_mfa_spans(b"defmodule D do\n def atom, do: :ok\nend\n", "elixir", [("D", "atom", 0)])
    assert inline_atom[("D", "atom", 0)]["definitions"]
    _assert_raises(extract_mfa_spans, elixir, "elixir", [("Demo", "greet", 3)])
    _assert_raises(extract_mfa_spans, b"defmodule Demo do\n def broken(x) do\n", "elixir", [("Demo", "broken", 1)])
    _assert_raises(extract_mfa_spans, b"defmodule Demo do\n def broken x do\n  x\n end\nend\n", "elixir", [("Demo", "broken", 1)])
    _assert_raises(extract_mfa_spans, b"defmodule Demo do\n def one, do: first\n  second\nend\n", "elixir", [("Demo", "one", 0)])

    erlang = b'''-module(demo).
-export([odd_name/2]).
% odd_name(0, 0) is a comment
odd_name({A, B}, [C, D]) when is_integer(A); is_atom(B) ->
    Text = "odd_name(0, 0) is not a call",
    case C of
      x -> odd_name({A, B}, [C, D]);
      _ -> ok
    end;
odd_name(X, Y) -> {X, Y}.
'strange-name'(A, B) -> {A, B}.
'''
    erlang_got = extract_mfa_spans(erlang, "erlang", [("demo", "odd_name", 2), ("demo", "strange-name", 2)])
    assert len(erlang_got[("demo", "odd_name", 2)]["definitions"]) == 2
    assert len(erlang_got[("demo", "odd_name", 2)]["references"]) == 1
    assert erlang_got[("demo", "strange-name", 2)]["definitions"][0]["text"].startswith("'strange-name'")
    assert "Text" not in str(erlang_got[("demo", "odd_name", 2)]["references"])
    _assert_raises(extract_mfa_spans, erlang, "erlang", [("demo", "odd_name", 1)])
    _assert_raises(extract_mfa_spans, b"-module(demo).\nmissing(X) -> X", "erlang", [("demo", "missing", 1)])
    _assert_raises(extract_mfa_spans, b"-module(demo).\nmissing(X) -> case X of a -> a", "erlang", [("demo", "missing", 1)])
    return {"elixir_cases": 10, "erlang_cases": 5}


__all__ = ["ObserverError", "extract_mfa_spans", "self_test"]
