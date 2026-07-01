// swift-tools-version: 6.3.1

import PackageDescription

let package = Package(
    name: "swift-builder-primitives",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26),
    ],
    products: [
        // MARK: - Grammar
        .library(
            name: "Builder Primitives",
            targets: ["Builder Primitives"]
        ),

        // MARK: - Test Support
        .library(
            name: "Builder Primitives Test Support",
            targets: ["Builder Primitives Test Support"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-primitives/swift-buffer-linear-primitives.git", branch: "main"),
        // `Buildable` refines `Initiable` (the empty-construction half); the
        // grow-and-build capability composes empty-init with one grow op. L1→L1,
        // acyclic ([MOD-032]): initialization-primitives has zero dependencies.
        .package(url: "https://github.com/swift-primitives/swift-initialization-primitives.git", branch: "main"),
        // E2 (storage-small-substrate.md): verbose Storage.Contiguous<Memory.Heap> needs direct deps (MemberImportVisibility).
        .package(url: "https://github.com/swift-primitives/swift-storage-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-memory-heap-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-memory-allocation-primitives.git", branch: "main"),
    ],
    targets: [
        // MARK: - Grammar
        .target(
            name: "Builder Primitives",
            dependencies: [
                .product(name: "Buffer Linear Primitives", package: "swift-buffer-linear-primitives"),
                .product(name: "Initialization Primitives", package: "swift-initialization-primitives"),
                .product(name: "Storage Contiguous Primitives", package: "swift-storage-primitives"),
                .product(name: "Memory Heap Primitives", package: "swift-memory-heap-primitives"),
                .product(name: "Memory Allocator Primitive", package: "swift-memory-allocation-primitives"),
            ]
        ),

        // MARK: - Test Support
        .target(
            name: "Builder Primitives Test Support",
            dependencies: [
                "Builder Primitives",
                .product(name: "Buffer Linear Primitives Test Support", package: "swift-buffer-linear-primitives"),
            ],
            path: "Tests/Support"
        ),

        // MARK: - Tests
        .testTarget(
            name: "Builder Primitives Tests",
            dependencies: [
                "Builder Primitives",
                "Builder Primitives Test Support",
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableExperimentalFeature("SuppressedAssociatedTypes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableUpcomingFeature("LifetimeDependence"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
