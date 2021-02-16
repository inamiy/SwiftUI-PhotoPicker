import Combine

extension Publishers
{
    struct ZipMany<Upstream>: Publisher where Upstream: Publisher
    {
        typealias Output = [Upstream.Output]
        typealias Failure = Upstream.Failure

        private let upstreams: [Upstream]

        init(_ upstreams: [Upstream])
        {
            self.upstreams = upstreams
        }

        func receive<S>(subscriber: S)
        where S: Subscriber, Self.Failure == S.Failure, Self.Output == S.Input
        {
            let initial = Just<[Upstream.Output]>([])
                .setFailureType(to: Failure.self)
                .eraseToAnyPublisher()

            let zipped = upstreams.reduce(into: initial) { result, upstream in
                result = result.zip(upstream) { elements, element in
                    elements + [element]
                }
                .eraseToAnyPublisher()
            }

            zipped.subscribe(subscriber)
        }
    }
}
