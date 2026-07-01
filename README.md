# Builder Primitives

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

A shared, macro-free result-builder grammar for declarative element collection — `Builder<Component>`, one generic `@resultBuilder` that any growable family composes to get its `X { 1; 2; if c { … } }` DSL without re-authoring the grammar.

---

## Quick Start

The cleanest path is the `Buildable` protocol. Conform a growable family by supplying empty construction (`Initiable`'s `init()`) and one neutral grow operation, `add(_:)`. In exchange the family receives the declarative `init(@Builder<Element> …)` for free — the accumulator type never appears in the family's own code:

```swift
import Builder_Primitives

extension Set.Ordered: Buildable {
    // init() is the set's empty construction (Initiable)
    public mutating func add(_ element: consuming Element) {
        _ = self.insert(element)          // per-family grow: dedup on insert
    }
}

let s = Set<Int>.Ordered {
    1
    2
    2                       // the dedup happens in `add`, not in the grammar
    if useThree { 3 }
}
```

Per-family behaviour (a set's deduplication, a dictionary's key-merge, a sorted container's ordered placement) lives in `add(_:)`, exactly where it would at any other call site. The grammar is identical across every family — it only collects elements, in order.

A family that does not conform to `Buildable` can reference `Builder` directly as the build attribute on an initializer and drain the collected buffer itself:

```swift
import Builder_Primitives

struct Bag {
    var storage: Buffer<Storage<Int>.Contiguous<Memory.Heap<Int>>>.Linear

    init(@Builder<Int> _ content: () -> Buffer<Storage<Int>.Contiguous<Memory.Heap<Int>>>.Linear) {
        self.storage = content()
    }
}

let bag = Bag {
    1
    2
    if useThree { 3 }
    if useThree { 4 } else { 99 }
    if #available(macOS 10.15, *) { 5 }
}
```

The full `build*` grammar — sequencing, `if`, `if`/`else`, `if #available` — is inherited; the family writes none of it.

Move-only (`~Copyable`) elements compose declaratively too — the grammar consumes and moves rather than copies:

```swift
struct FileHandle: ~Copyable { /* … */ }

struct Handles: ~Copyable {
    var storage: Buffer<Storage<FileHandle>.Contiguous<Memory.Heap<FileHandle>>>.Linear

    init(@Builder<FileHandle> _ content: () -> Buffer<Storage<FileHandle>.Contiguous<Memory.Heap<FileHandle>>>.Linear) {
        self.storage = content()
    }
}
```

For `Copyable` elements, an array literal or any `Swift.Sequence` collects in one statement:

```swift
let ints = Bag {
    1
    [3, 5]      // array literal
    6...8       // range
}
```

---

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/swift-primitives/swift-builder-primitives.git", branch: "main")
]
```

```swift
.target(
    name: "App",
    dependencies: [
        .product(name: "Builder Primitives", package: "swift-builder-primitives"),
    ]
)
```

Requires Swift 6.3.1 and macOS 26 / iOS 26 / tvOS 26 / watchOS 26 / visionOS 26 (or the matching Linux / Windows toolchain).

---

## Architecture

Two library products. Depends on four primitives: `swift-buffer-linear-primitives`, `swift-initialization-primitives`, `swift-storage-primitives`, and `swift-memory-heap-primitives` (the verbose `Storage.Contiguous<Memory.Heap>` accumulator requires each as a direct dependency).

| Product | Target | When to import |
|---------|--------|----------------|
| `Builder Primitives` | `Sources/Builder Primitives/` | Whenever a type composes the shared collection grammar via `@Builder<Component>`, or conforms to `Buildable`. |
| `Builder Primitives Test Support` | `Tests/Support/` | In test targets that need the toy consumer fixtures. |

### Accumulator

`Builder` collects into `Buffer<Storage<Component>.Contiguous<Memory.Heap<Component>>>.Linear` — the lowest-level growable, `~Copyable`-capable linear storage in the ecosystem, below every collection family. It is deliberately not `Swift.Array` (which requires `Component: Copyable`) and not a concrete family container (which would couple the grammar to one family). A composing family drains the returned buffer into its own structure.

### What the grammar does not support

- **`for` loops.** Swift's result-builder transform lowers a `for` loop through `buildArray(_: [partial])` — a `Swift.Array` of the partial result. The partial result is `Buffer<Storage<Component>.Contiguous<Memory.Heap<Component>>>.Linear`, which is itself `~Copyable`, so that array is illegal for any `Component`. Use an array literal or a `Swift.Sequence` (for `Copyable` elements), or imperative construction.
- **`~Escapable` components.** The accumulator stores its elements, which requires them to be `Escapable`; a collect-and-return grammar inherently escapes the collected values.

This package ships only the grammar (`Builder`) and the grow-and-build capability (`Buildable`). Per-family DSL integrations are a separate, later workstream.

Foundation-free.

---

## Platform Support

| Platform | Status |
|----------|--------|
| macOS 26 | Full support |
| Linux | Full support |
| Windows | Full support |
| iOS / tvOS / watchOS / visionOS | Supported |

---

## Community

<!-- BEGIN: discussion -->
<!-- Discussion thread created at publication. -->
<!-- END: discussion -->

## License

Apache 2.0. See [LICENSE.md](LICENSE.md).
