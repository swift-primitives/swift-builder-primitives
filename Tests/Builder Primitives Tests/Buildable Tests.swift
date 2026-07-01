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

import Builder_Primitives_Test_Support
import Testing

@Suite
struct `Buildable Tests` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}
}

// MARK: - Unit

extension `Buildable Tests`.Unit {

    @Test
    func `the generic default init builds a conformer from a Builder body`() {
        let unique = Fixture.Unique {
            1
            2
            3
        }
        #expect(unique.elements == [1, 2, 3])
    }

    @Test
    func `per-family add semantics apply during the build (dedup)`() {
        let unique = Fixture.Unique {
            1
            2
            2
            3
            1
        }
        #expect(unique.elements == [1, 2, 3])
    }
}

// MARK: - Edge Case

extension `Buildable Tests`.`Edge Case` {

    @Test
    func `an empty body yields the Initiable empty value`() {
        let unique = Fixture.Unique {}
        #expect(unique.elements == [])
    }

    @Test
    func `a bare if contributes only when its condition is true`() {
        let unique = Fixture.Unique {
            1
            if true { 2 }
            if false { 99 }
        }
        #expect(unique.elements == [1, 2])
    }
}

// MARK: - Integration

extension `Buildable Tests`.Integration {

    @Test
    func `the same generic default serves a move-only conformer`() {
        let flag = true
        let sink = Fixture.Sink {
            Fixture.Token(10)
            Fixture.Token(20)
            if flag { Fixture.Token(30) }
        }
        #expect(sink.ids() == [10, 20, 30])
    }

    @Test
    func `a Copyable conformer admits Sequence bulk-add through the shared grammar`() {
        let flag = true
        let unique = Fixture.Unique {
            1
            if flag { [2, 3, 2] }
            4...5
        }
        #expect(unique.elements == [1, 2, 3, 4, 5])
    }
}
