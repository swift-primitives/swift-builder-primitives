public import Builder_Primitives
import Memory_Allocator_Primitive
import Memory_Heap_Primitives
import Storage_Contiguous_Primitives

extension Fixture {

    public struct Tokens: ~Copyable {

        public var storage: Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Fixture.Token>>.Linear

        public init(@Builder<Fixture.Token> _ content: () -> Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Fixture.Token>>.Linear) {
            self.storage = content()
        }
    }
}

extension Fixture.Tokens {

    public consuming func ids() -> [Int] {
        var out: [Int] = []
        var rest = storage
        while !rest.isEmpty {
            out.append(rest.remove.first().id)
        }
        return out
    }
}
