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

public import Builder_Primitives
import Memory_Allocator_Primitive
import Memory_Heap_Primitives
import Storage_Contiguous_Primitives

extension Fixture {
    /// A move-only (`~Copyable`) toy family conforming ``Buildable`` over the
    /// `~Copyable` ``Fixture/Token``: its ``add(_:)`` appends every element. It
    /// inherits the same generic ``Buildable`` default `init` as the `Copyable`
    /// ``Fixture/Unique`` — one default serves both copyability worlds, moving
    /// each collected token rather than copying it.
    public struct Sink: ~Copyable {
        /// The collected tokens, in build order.
        public var storage: Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Fixture.Token>>.Linear

        /// Creates the empty value — the `Initiable` witness `Buildable` refines.
        public init() {
            self.storage = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Fixture.Token>>.Linear(minimumCapacity: .zero)
        }
    }
}

extension Fixture.Sink: Buildable {
    /// Per-family grow: appends every element (no deduplication).
    public mutating func add(_ element: consuming Fixture.Token) {
        storage.append(consume element)
    }
}

extension Fixture.Sink {
    /// Drains the collected tokens into their identities, in build order.
    public consuming func ids() -> [Int] {
        var out: [Int] = []
        var rest = storage
        while !rest.isEmpty {
            out.append(rest.remove.first().id)
        }
        return out
    }
}
