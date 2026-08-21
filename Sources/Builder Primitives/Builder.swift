public import Buffer_Linear_Primitives
public import Memory_Allocator_Primitive
public import Memory_Heap_Primitives
public import Storage_Contiguous_Primitives

@resultBuilder
public enum Builder<Component: ~Copyable> {}

extension Builder where Component: ~Copyable {

    @inlinable
    public static func buildExpression(
        _ expression: consuming Component
    ) -> Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Component>>.Linear {
        var result = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Component>>.Linear(
            minimumCapacity: .one
        )
        result.append(consume expression)
        return result
    }

    @inlinable
    public static func buildExpression(
        _ expression:
            consuming Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Component>>.Linear
    ) -> Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Component>>.Linear {
        consume expression
    }

    @inlinable
    public static func buildExpression(
        _ expression: consuming Component?
    ) -> Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Component>>.Linear {
        var result = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Component>>.Linear(
            minimumCapacity: .zero
        )
        if let value = consume expression {
            result.append(consume value)
        }
        return result
    }
}

extension Builder where Component: ~Copyable {

    @inlinable
    public static func buildPartialBlock(
        first: consuming Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Component>>.Linear
    ) -> Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Component>>.Linear {
        consume first
    }

    @inlinable
    public static func buildPartialBlock(
        first: Void
    ) -> Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Component>>.Linear {
        Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Component>>.Linear(
            minimumCapacity: .zero
        )
    }

    @inlinable
    public static func buildPartialBlock(
        first: Never
    ) -> Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Component>>.Linear {}

    @inlinable
    public static func buildPartialBlock(
        accumulated:
            consuming Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Component>>.Linear,
        next: consuming Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Component>>.Linear
    ) -> Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Component>>.Linear {
        var result = consume accumulated
        var rest = consume next
        while !rest.isEmpty {
            result.append(rest.remove.first())
        }
        return result
    }
}

extension Builder where Component: ~Copyable {

    @inlinable
    public static func buildBlock()
        -> Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Component>>.Linear
    {
        Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Component>>.Linear(
            minimumCapacity: .zero
        )
    }
}

extension Builder where Component: ~Copyable {

    @inlinable
    public static func buildOptional(
        _ component:
            consuming Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Component>>.Linear?
    ) -> Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Component>>.Linear {
        if let result = consume component {
            return consume result
        }
        return Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Component>>.Linear(
            minimumCapacity: .zero
        )
    }

    @inlinable
    public static func buildEither(
        first: consuming Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Component>>.Linear
    ) -> Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Component>>.Linear {
        consume first
    }

    @inlinable
    public static func buildEither(
        second:
            consuming Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Component>>.Linear
    ) -> Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Component>>.Linear {
        consume second
    }

    @inlinable
    public static func buildLimitedAvailability(
        _ component:
            consuming Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Component>>.Linear
    ) -> Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Component>>.Linear {
        consume component
    }
}

extension Builder where Component: Copyable {

    @inlinable
    public static func buildExpression<S: Swift.Sequence>(
        _ expression: S
    ) -> Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Component>>.Linear
    where S.Element == Component {
        var result = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Component>>.Linear(
            minimumCapacity: .zero
        )
        for value in expression {
            result.append(value)
        }
        return result
    }
}
