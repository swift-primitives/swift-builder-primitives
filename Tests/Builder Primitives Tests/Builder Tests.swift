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
struct `Builder Tests` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}
    @Suite(.serialized) struct Performance {}
}

// MARK: - Unit

extension `Builder Tests`.Unit {

    @Test
    func `single expressions collect in order`() {
        let tokens = Fixture.Tokens {
            Fixture.Token(1)
            Fixture.Token(2)
            Fixture.Token(3)
        }
        #expect(tokens.ids() == [1, 2, 3])
    }

    @Test
    func `an empty body builds an empty result`() {
        let tokens = Fixture.Tokens {}
        #expect(tokens.ids() == [])
    }
}

// MARK: - Edge Case

extension `Builder Tests`.`Edge Case` {

    @Test
    func `a bare if includes its elements only when true`() {
        let present = Fixture.Tokens {
            Fixture.Token(1)
            if true { Fixture.Token(2) }
        }
        #expect(present.ids() == [1, 2])

        let absent = Fixture.Tokens {
            Fixture.Token(1)
            if false { Fixture.Token(2) }
        }
        #expect(absent.ids() == [1])
    }

    @Test
    func `if-else selects the taken branch`() {
        let first = Fixture.Tokens {
            if true { Fixture.Token(10) } else { Fixture.Token(99) }
        }
        #expect(first.ids() == [10])

        let second = Fixture.Tokens {
            if false { Fixture.Token(10) } else { Fixture.Token(99) }
        }
        #expect(second.ids() == [99])
    }
}

// MARK: - Integration

extension `Builder Tests`.Integration {

    @Test
    func `the maximal move-only grammar composes end to end`() {
        let flag = true
        let tokens = Fixture.Tokens {
            Fixture.Token(1)
            Fixture.Token(2)
            if flag { Fixture.Token(3) }
            if flag { Fixture.Token(4) } else { Fixture.Token(99) }
            if #available(macOS 10.15, *) { Fixture.Token(5) }
        }
        #expect(tokens.ids() == [1, 2, 3, 4, 5])
    }

    @Test
    func `Copyable components admit array-literal and range bulk-add`() {
        let flag = true
        let ints = Fixture.Ints {
            1
            2
            if flag { [3, 5] }
            6...8
        }
        #expect(ints.values() == [1, 2, 3, 5, 6, 7, 8])
    }
}

// MARK: - Performance

extension `Builder Tests`.Performance {

    @Test
    func `repeated declarative construction stays correct under load`() {
        for _ in 0..<1_000 {
            let tokens = Fixture.Tokens {
                Fixture.Token(1)
                Fixture.Token(2)
            }
            #expect(tokens.ids() == [1, 2])
        }
    }
}
