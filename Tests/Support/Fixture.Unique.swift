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
    /// A `Copyable` toy family conforming ``Buildable`` over `Int`, modelling a
    /// set: its ``add(_:)`` deduplicates, so the family inherits the
    /// `Unique { 1; 2; 2 }` DSL *for free* from the generic ``Buildable``
    /// default and applies its own grow semantics during the build.
    public struct Unique {
        /// The collected elements, first occurrence wins, order preserved.
        public var elements: [Int]

        /// Creates the empty value — the `Initiable` witness `Buildable` refines.
        public init() {
            self.elements = []
        }
    }
}

extension Fixture.Unique: Buildable {
    /// Per-family grow: appends only first occurrences (set deduplication).
    public mutating func add(_ element: consuming Int) {
        if !elements.contains(element) {
            elements.append(element)
        }
    }
}
