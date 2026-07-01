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
//  Buildable.swift
//  swift-builder-primitives
//
//  The generic grow-and-build capability: `Initiable` + one neutral
//  single-element grow op, with the declarative `X { … }` DSL as a free default.
//

public import Buffer_Linear_Primitives
public import Initialization_Primitives
public import Memory_Allocator_Primitive
public import Memory_Heap_Primitives
public import Storage_Contiguous_Primitives

/// A growable discipline that can be constructed declaratively with the shared
/// ``Builder`` grammar.
///
/// `Buildable` is the cross-domain *build* capability. It composes `Initiable`
/// (empty construction — `init()`) with one neutral, single-element grow
/// operation, ``add(_:)``. A conformer supplies only those two primitives; in
/// exchange it receives, for free, the declarative `init(@Builder<Element> …)`
/// that turns an `X { 1; 2; if c { … } }` body into a finished value — without
/// re-authoring the grammar.
///
/// ```swift
/// extension Set.Ordered: Buildable {
///     // init() is the set's empty construction (Initiable)
///     public mutating func add(_ element: consuming Element) {
///         _ = self.insert(element)          // per-family grow: dedup on insert
///     }
/// }
///
/// let s = Set<Int>.Ordered { 1; 2; 2; if flag { 3 } }   // the DSL, for free
/// ```
///
/// ## Per-family semantics live in `add`, not in the grammar
///
/// The ``Builder`` grammar is identical across every family — it only collects
/// elements, in order. The behaviour that distinguishes one family from another
/// (a set's deduplication, a multiset's counting, a sorted container's ordered
/// placement) belongs in ``add(_:)``, exactly as it would at any other call
/// site. The default `init` drains the grammar-collected elements through
/// ``add(_:)`` one at a time, so each element is subject to the family's own
/// grow semantics.
///
/// ## The grow operation discards any result
///
/// ``add(_:)`` returns `Void`. Families whose native grow reports a result — a
/// set's `insert` returning `(inserted:index:)`, a dictionary's `updateValue`
/// returning the displaced value — forward to it and discard the report: the
/// build context has no use for per-element grow results. Discarding is what
/// lets one neutral `add` unify families with otherwise-divergent grow
/// signatures.
///
/// ## `~Copyable` conformers
///
/// `Buildable` (like `Initiable`) suppresses `Copyable`, and ``add(_:)`` takes
/// its element `consuming`, so move-only growable disciplines conform unchanged —
/// the default `init` *moves* each collected element into the value rather than
/// copying it. `Copyable` conformers are admitted unchanged; the suppression
/// only widens the conformer set.
///
/// ## `Element` and the accumulator
///
/// The associated `Element` also suppresses `Copyable`. The default `init`
/// collects into the grammar's `Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Element>>.Linear` accumulator and drains
/// it by consuming `remove`, so the whole build path is move-correct for
/// `~Copyable` elements. The grammar's documented residuals apply unchanged:
/// `for` loops (no `buildArray`) and `~Escapable` elements are unsupported; a
/// `Copyable` element additionally admits a `Swift.Sequence` expression in the
/// body.
public protocol Buildable: Initiable, ~Copyable {
    /// The element this discipline grows by.
    associatedtype Element: ~Copyable

    /// Grows the value by one element, applying the family's own grow semantics.
    ///
    /// The single primitive a conformer must supply beyond `Initiable`'s
    /// `init()`. Per-family behaviour — deduplication, key-merge, ordered
    /// placement — lives here; the ``Builder`` grammar that feeds it is identical
    /// across all families. Any result the family's native grow reports is
    /// discarded.
    ///
    /// - Parameter element: The element to add, consumed into the value.
    mutating func add(_ element: consuming Element)
}

// MARK: - Declarative Construction (free default)

extension Buildable where Self: ~Copyable {

    /// Builds a value declaratively from a ``Builder`` body.
    ///
    /// The free default that gives every `Buildable` conformer the
    /// `X { 1; 2; if c { … } }` DSL without re-authoring the grammar: start from
    /// `Initiable`'s empty value, then drain the grammar-collected elements
    /// through ``add(_:)`` in order, so each is subject to the family's grow
    /// semantics.
    ///
    /// ## Typed throws
    ///
    /// `Initiable.init()` is `throws(Failure)`, so this declarative initializer
    /// propagates that same typed channel. When the conformer's `Failure == Never`
    /// (the common case — `Set`, `Array`, ordered containers), the `throws(Never)`
    /// collapses and no `try` is needed at the `X { … }` call site; only a conformer
    /// with a fallible `init()` requires `try`.
    ///
    /// - Parameter content: A ``Builder`` body collecting the elements to add.
    /// - Throws: `Failure` if the conformer's empty construction (`init()`) fails.
    @inlinable
    public init(@Builder<Element> _ content: () -> Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Element>>.Linear) throws(Failure) {
        try self.init()
        var buffer = content()
        while !buffer.isEmpty {
            self.add(buffer.remove.first())
        }
    }
}
