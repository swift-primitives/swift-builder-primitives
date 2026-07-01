# ``Builder_Primitives``

@Metadata {
    @DisplayName("Builder Primitives")
    @TitleHeading("Swift Institute — Primitives Layer")
}

A shared, macro-free result-builder grammar for declarative element collection.

## Overview

`Builder Primitives` ships one generic `@resultBuilder`, ``Builder``, that any
growable family composes to obtain a declarative `X { 1; 2; if c { … } }` DSL
**without re-authoring the grammar**. The full set of `build*` rules lives here
once, generic over the `Component` element type; a composing family supplies
only its storage and a one-line `@Builder`-attributed `init`.

It is macro-free: ``Builder`` is a `@resultBuilder` type — a distinct Swift
language feature — not a macro. Per-family semantics (deduplication, key-merge)
belong in the consuming `init`, never in the grammar.

A family that conforms ``Buildable`` — supplying empty construction (`Initiable`)
plus one neutral grow op, ``Buildable/add(_:)`` — receives the
`X { 1; 2; if c { … } }` initializer entirely for free from a protocol-extension
default, without writing even the one-line `@Builder` `init`.

### Accumulator

The grammar collects into `Buffer<Storage<Component>.Heap>.Linear` — the lowest-level
growable, `~Copyable`-capable linear storage in the ecosystem, below every
collection family. It is deliberately not `Swift.Array` (Copyable-only) and not
a concrete family container.

### Reach

- **`~Copyable` components** compose via the maximal grammar (single and
  optional expressions, `buildPartialBlock`, `if`, `if`/`else`,
  `if #available`).
- **`Copyable` components** additionally admit array literals and any
  `Swift.Sequence` via a conditional `buildExpression`.
- **`for` loops** are unsupported (the transform requires a `Swift.Array` of the
  `~Copyable` partial result) — use a `Swift.Sequence` instead.
- **`~Escapable` components** are unsupported (a collect-and-return grammar
  escapes the collected values).

## Topics

### Grammar

- ``Builder``

### Capability

- ``Buildable``
