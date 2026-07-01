# Builder grammar — design decision and committed roadmap

**Status:** DECISION (2026-05-29). Records the design that shipped in
`swift-builder-primitives` 0.x and the committed follow-on program. Supersedes
the accumulator section of the design-gate artifact
(`HANDOFF-builder-primitives-design-gate.md`), which recommended the
protocol-carried shape (Approach C); the principal locked Approach A on the
`Buffer.Linear` substrate.

## What shipped

One generic, macro-free `@resultBuilder Builder<Component: ~Copyable>` (the
package namesake — see naming note below) collecting into
`Buffer<Component>.Linear`. A composing family references it directly via the
build attribute and consumes the accumulator in its `init`:

```swift
struct Bag {
    var storage: Buffer<Int>.Linear
    init(@Builder<Int> _ content: () -> Buffer<Int>.Linear) { self.storage = content() }
}
```

### Decided design axes

| Axis | Decision | Why |
|------|----------|-----|
| Shape | **A** — one shared generic `@resultBuilder`, referenced directly; per-family semantics in the finalize `init`, never in `build*` | The grammar is identical across families; per-family behaviour (set dedup, dict key-merge) is a property of the consuming `init`, not the grammar. No family needs a per-method override (the one structurally-different family, a hierarchical tree, writes a bespoke builder regardless). |
| Accumulator | **`Buffer<Component>.Linear`** | The lowest `~Copyable`-capable growable substrate, below every family. Not `Swift.Array` (Copyable-only; the [DS-021] stdlib-fallback anti-pattern). Not the institute `Array` (would make `builder → array` and, with a future `array`-DSL → builder, a [MOD-032] cycle). |
| `build*` placement | explicit `extension Builder where Component: ~Copyable` | A bare `extension` on a `~Copyable`-generic type implicitly re-imposes `Copyable` ([COPY-FIX-003]); the suppression must be restated. |
| Naming | top-level **`Builder<Component>`** (namesake) | Per [API-NAME-001a], a single-type package must not create a speculative single-type namespace (`Builder.<noun>` where `Builder` holds one type is a variant label). Promote to `Builder.<noun>` when the β program (below) adds a second type — a mechanical rename, no consumer breakage pre-1.0. |

### Reachable surface (empirically characterised)

- **`~Copyable` components — maximal grammar, 0 added witness dispatch:**
  single + optional `buildExpression`, `buildPartialBlock`
  (`first` / `Void` / `Never` / `accumulated:next:`), `buildBlock`,
  `buildOptional`, `buildEither`, `buildLimitedAvailability`. The specialised
  build path emits **0 `witness_method`** — identical to a hand-written
  imperative `Buffer.Linear` construction (baseline-confirmed); the grammar is
  pure `@inlinable` static dispatch.
- **`Copyable` components — additionally** a `Swift.Sequence` `buildExpression`
  (`[1, 3, 5]` array literals, `Range`, lazy chains), behind
  `where Component: Copyable`.

### Proven-irreducible residual (first-principles, not first-failure)

- **`for` loops / `buildArray` — unsupported for any `Component`.** Swift's
  result-builder transform lowers a `for` loop through
  `buildArray(_: [PartialResult])`. `PartialResult` is `Buffer<Component>.Linear`,
  which is itself `~Copyable`, so `Swift.Array<Buffer<Component>.Linear>` is
  rejected: `error: 'Array' requires that 'Component' conform to 'Copyable'`.
  Omitted, matching the production `Buffer.Linear.Builder` / `Array.Builder`.
  Substitute: a `Swift.Sequence` expression (Copyable) or imperative building.
- **`~Escapable` components — unsupported.** The accumulator stores its elements
  and so requires them `Escapable`: `error: type '…' does not conform to
  protocol 'Escapable'`. A collect-and-return grammar inherently escapes the
  collected values, which `~Escapable` forbids.

## Committed follow-on roadmap (post-A1; NOT acted on here)

This package ships the standalone grammar only. The following are committed but
sequenced after the A1 Set.Ordered work and authorized separately — they touch
the Set/Array stacks (A1's edit zone) and must coordinate accordingly.

1. **Per-family integration packages** — `swift-array-builder-primitives`,
   `swift-set-builder-primitives`, … each a [MOD-014] integration package
   composing this grammar for one family's `X { … }` DSL. The existing
   `Array.Builder` and `Set.Builder` (structurally-identical re-authored
   grammars) are extracted to consume this package.
2. **`Set.Buildable.Protocol.init()` → `Initiable` convergence.** `Set.Buildable.Protocol`
   is `init()` + `insert`; its `init()` half is the cross-domain
   empty-construction capability that should refine `Initiable`
   (`swift-initialization-primitives`). This is the A3 framing realized.
3. **Grow-side capability gap.** `swift-collection-primitives` supplies only the
   read/drain/shrink side (`Collection.Protocol`, `Remove`, `Clearable`,
   `ForEach`) — there is **no** grow side (no `append`, no empty `init()`). A
   builder accumulator needs empty-init (`Initiable`) + single-element append +
   drain. The append is the missing cross-family capability.
4. **β capability-generic end-state.** The model-consistent end-state is a
   grammar generic over an accumulator constrained by
   `Initiable` + a (new) grow-side append capability + `Collection` drain — so
   each family collects directly into its own container with no convert pass and
   no concrete-substrate coupling. Deferred behind a separately-authorized
   program; do not retrofit onto this 0.x package without that authorization.

## References

- Production precedents: `swift-buffer-linear-primitives` `Buffer.Linear.Builder`,
  `swift-array-primitives` `Array.Builder`, `swift-set-primitives` `Set.Builder`.
- Design-gate probes (throwaway): `/tmp/breprobe2` (Buffer.Linear re-probe),
  `/tmp/builderA-*` / `/tmp/approachB-*` / `/tmp/approachC-*` (round-1 A/B/C).
