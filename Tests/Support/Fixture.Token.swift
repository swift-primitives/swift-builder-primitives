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

extension Fixture {
    /// A move-only (`~Copyable`) element, used to prove the grammar collects
    /// non-copyable components.
    public struct Token: ~Copyable {
        /// The token's identity.
        public var id: Int

        /// Creates a token with the given identity.
        public init(_ id: Int) {
            self.id = id
        }
    }
}
