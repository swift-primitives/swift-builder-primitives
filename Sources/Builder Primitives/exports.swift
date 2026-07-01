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

// The accumulator type `Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Component>>.Linear` appears throughout this
// package's public API (every `build*` rule returns it, and a composing
// family's `init(@Builder<Component> …)` consumes it). Re-export it so
// consumers reach the accumulator without a second import.
@_exported public import Buffer_Linear_Primitives
// `Buildable` refines `Initiable`, so `Initiable` appears in `Buildable`'s
// public inheritance clause. Re-export it so a conformer satisfying the
// `init()` requirement reaches `Initiable` without a second import ([PKG-DEP-003]).
@_exported public import Initialization_Primitives
