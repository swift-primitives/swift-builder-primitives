import Builder_Primitives

extension Fixture {

    public struct Token: ~Copyable {

        public var id: Int

        public init(_ id: Int) {
            self.id = id
        }
    }
}
