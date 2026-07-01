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
    /// A move-only toy family composing ``Builder`` over `~Copyable` `Token`
    /// elements. Demonstrates the intended composition: the family writes only
    /// its storage and its `@Builder`-attributed `init`; the grammar is
    /// inherited wholesale.
    public struct Tokens: ~Copyable {
        /// The collected tokens.
        public var storage: Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Fixture.Token>>.Linear

        /// Builds the family from a declarative `Builder` body.
        public init(@Builder<Fixture.Token> _ content: () -> Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Fixture.Token>>.Linear) {
            self.storage = content()
        }
    }
}

extension Fixture.Tokens {
    /// Drains the collected tokens into their identities, in collection order.
    public consuming func ids() -> [Int] {
        var out: [Int] = []
        var rest = storage
        while !rest.isEmpty {
            out.append(rest.remove.first().id)
        }
        return out
    }
}
