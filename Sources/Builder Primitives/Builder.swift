// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-primitives open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-primitives project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

//
//  Builder.swift
//  swift-builder-primitives
//
//  The shared, macro-free element-collection result-builder grammar.
//

public import Buffer_Linear_Primitives
public import Memory_Allocator_Primitive
public import Memory_Heap_Primitives
public import Storage_Contiguous_Primitives

/// The shared result-builder grammar for declarative element collection.
///
/// `Builder` is a single, generic `@resultBuilder` that any family composes to
/// obtain a declarative `X { 1; 2; if c { … } }` DSL **without re-authoring the
/// grammar**. The full set of `build*` rules — sequencing, conditionals,
/// optionals, either-branches, limited-availability — lives here once, generic
/// over the `Component` element type. A family supplies only its intermediate
/// type and its `init` entry point.
///
/// ## Composing the grammar
///
/// A family references `Builder` directly as the build attribute on an
/// initializer, instantiated with its element type, and consumes the collected
/// elements in the body:
///
/// ```swift
/// import Builder_Primitives
///
/// struct Bag {
///     var storage: Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear
///     init(@Builder<Int> _ content: () -> Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear) {
///         self.storage = content()
///     }
/// }
///
/// let bag = Bag {
///     1
///     2
///     if flag { 3 }
/// }
/// ```
///
/// The family writes no `build*` methods. Per-family semantics (a set's
/// deduplication, a dictionary's key-merge) belong in the `init` that consumes
/// the collected elements — never in the grammar, which is identical across
/// families.
///
/// ## Accumulator: `Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Component>>.Linear`
///
/// The grammar collects into the institute's `Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Component>>.Linear` — the
/// lowest-level growable, `~Copyable`-capable linear storage in the ecosystem,
/// below every collection family. It is deliberately *not* `Swift.Array`
/// (which requires `Component: Copyable`) and *not* a concrete family container
/// (which would couple this grammar to one family and forbid the others). Each
/// family drains the returned buffer into its own structure.
///
/// ## `~Copyable` components
///
/// `Component` suppresses `Copyable`, so move-only elements compose
/// declaratively — the buffer is built by consuming append, and the grammar
/// moves partial results rather than copying them:
///
/// ```swift
/// struct FileHandle: ~Copyable { /* … */ }
/// let handles = Bag<FileHandle> {
///     FileHandle()
///     FileHandle()
/// }
/// ```
///
/// ## What the grammar does *not* support
///
/// - **`for` loops are unsupported, for any element type.** Swift's
///   result-builder transform lowers a `for` loop through
///   `buildArray(_: [Component-partial])`, i.e. a `Swift.Array` of the partial
///   result. The partial result here is `Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Component>>.Linear`, which is
///   itself `~Copyable`, so `Swift.Array<Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Component>>.Linear>` is illegal
///   regardless of `Component`. `buildArray` is therefore omitted. Use
///   imperative construction (`var b = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E>>.Linear(...); b.append(...)`)
///   for loop-based building.
/// - **`~Escapable` components are unsupported.** The accumulator stores its
///   elements, which requires them to be `Escapable`; a collect-and-return
///   grammar inherently escapes the collected values, which `~Escapable`
///   forbids.
///
/// For `Copyable` components, a `[1, 3, 5]` array literal — or any
/// `Swift.Sequence` such as a `Range` — is accepted via the conditional
/// `buildExpression` overload (`Builder` `where Component: Copyable`); this is
/// the supported substitute for the absent `for` loop.
@resultBuilder
public enum Builder<Component: ~Copyable> {}

// MARK: - Expression Building

extension Builder where Component: ~Copyable {

    /// Lifts a single element into a one-element partial result.
    @inlinable
    public static func buildExpression(_ expression: consuming Component) -> Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Component>>.Linear {
        var result = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Component>>.Linear(minimumCapacity: .one)
        result.append(consume expression)
        return result
    }

    /// Passes an already-built buffer through unchanged.
    @inlinable
    public static func buildExpression(
        _ expression: consuming Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Component>>.Linear
    ) -> Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Component>>.Linear {
        consume expression
    }

    /// Lifts an optional element into an empty-or-one-element partial result.
    @inlinable
    public static func buildExpression(_ expression: consuming Component?) -> Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Component>>.Linear {
        var result = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Component>>.Linear(minimumCapacity: .zero)
        if let value = consume expression {
            result.append(consume value)
        }
        return result
    }
}

// MARK: - Partial Block Building

extension Builder where Component: ~Copyable {

    /// Begins accumulation from the first partial result.
    @inlinable
    public static func buildPartialBlock(
        first: consuming Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Component>>.Linear
    ) -> Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Component>>.Linear {
        consume first
    }

    /// Begins accumulation from an empty statement (`Void`).
    @inlinable
    public static func buildPartialBlock(first: Void) -> Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Component>>.Linear {
        Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Component>>.Linear(minimumCapacity: .zero)
    }

    /// Begins accumulation from an uninhabited statement (`Never`).
    @inlinable
    public static func buildPartialBlock(first: Never) -> Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Component>>.Linear {}

    /// Appends the next partial result to the accumulated one, preserving order.
    @inlinable
    public static func buildPartialBlock(
        accumulated: consuming Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Component>>.Linear,
        next: consuming Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Component>>.Linear
    ) -> Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Component>>.Linear {
        var result = consume accumulated
        var rest = consume next
        while !rest.isEmpty {
            result.append(rest.remove.first())
        }
        return result
    }
}

// MARK: - Block Building

extension Builder where Component: ~Copyable {

    /// Builds an empty block into an empty partial result.
    @inlinable
    public static func buildBlock() -> Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Component>>.Linear {
        Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Component>>.Linear(minimumCapacity: .zero)
    }
}

// MARK: - Control Flow

extension Builder where Component: ~Copyable {

    /// Builds a bare `if` (no `else`) — the absent branch contributes nothing.
    @inlinable
    public static func buildOptional(
        _ component: consuming Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Component>>.Linear?
    ) -> Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Component>>.Linear {
        if let result = consume component {
            return consume result
        }
        return Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Component>>.Linear(minimumCapacity: .zero)
    }

    /// Builds the first branch of an `if`/`else`.
    @inlinable
    public static func buildEither(
        first: consuming Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Component>>.Linear
    ) -> Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Component>>.Linear {
        consume first
    }

    /// Builds the second branch of an `if`/`else`.
    @inlinable
    public static func buildEither(
        second: consuming Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Component>>.Linear
    ) -> Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Component>>.Linear {
        consume second
    }

    // `buildArray` is intentionally omitted — see the type's documentation:
    // the transform requires `Swift.Array<Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Component>>.Linear>`, which is
    // illegal because the partial result is itself `~Copyable`. `for` loops are
    // therefore unsupported.

    /// Builds an `if #available(…)` branch.
    @inlinable
    public static func buildLimitedAvailability(
        _ component: consuming Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Component>>.Linear
    ) -> Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Component>>.Linear {
        consume component
    }
}

// MARK: - Sequence Bulk-Add (Copyable components only)

extension Builder where Component: Copyable {

    /// Bulk-adds any `Swift.Sequence` — an array literal (`[1, 3, 5]`), a
    /// `Range`, a lazy chain — in one statement.
    ///
    /// Available only when `Component: Copyable`, because `Swift.Sequence`
    /// iteration copies its elements. This is the supported substitute for the
    /// absent `for` loop: write the sequence as a single expression rather than
    /// iterating in the builder body.
    @inlinable
    public static func buildExpression<S: Swift.Sequence>(_ expression: S) -> Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Component>>.Linear
    where S.Element == Component {
        var result = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Component>>.Linear(minimumCapacity: .zero)
        for value in expression {
            result.append(value)
        }
        return result
    }
}
