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
//  Builder Primitives Test Support.swift
//  swift-builder-primitives
//
//  Toy consumer families that compose the shared Builder grammar, exercising
//  both the ~Copyable and Copyable element paths.
//

/// Namespace for test fixtures — toy families that compose ``Builder`` over a
/// `Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Component>>.Linear` accumulator, standing in for the real growable
/// disciplines (the package stays isolated and does not depend on any family).
public enum Fixture {}
