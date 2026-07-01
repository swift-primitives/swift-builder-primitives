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
    /// A Copyable toy family composing ``Builder`` over `Int` elements.
    /// Exercises the `where Component: Copyable` `Swift.Sequence` bulk-add
    /// (array literals and ranges). Itself `~Copyable` because its
    /// `Buffer.Linear` storage is.
    public struct Ints: ~Copyable {
        /// The collected integers.
        public var storage: Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear

        /// Builds the family from a declarative `Builder` body.
        public init(@Builder<Int> _ content: () -> Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear) {
            self.storage = content()
        }
    }
}

extension Fixture.Ints {
    /// Drains the collected integers, in collection order.
    public consuming func values() -> [Int] {
        var out: [Int] = []
        var rest = storage
        while !rest.isEmpty {
            out.append(rest.remove.first())
        }
        return out
    }
}
