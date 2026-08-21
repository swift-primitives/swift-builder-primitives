public import Builder_Primitives
import Memory_Allocator_Primitive
import Memory_Heap_Primitives
import Storage_Contiguous_Primitives

extension Fixture {

    public struct Sink: ~Copyable {

        public var storage: Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Fixture.Token>>.Linear

        public init() {
            self.storage = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Fixture.Token>>.Linear(minimumCapacity: .zero)
        }
    }
}

extension Fixture.Sink: Buildable {

    public mutating func add(_ element: consuming Fixture.Token) {
        storage.append(consume element)
    }
}

extension Fixture.Sink {

    public consuming func ids() -> [Int] {
        var out: [Int] = []
        var rest = storage
        while !rest.isEmpty {
            out.append(rest.remove.first().id)
        }
        return out
    }
}
