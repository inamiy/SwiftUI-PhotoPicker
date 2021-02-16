import Foundation
import PhotosUI
import Combine

// MARK: - PickerPattern

/// `PHPickerFilter` filter pattern with data-loading support.
public struct PickerPattern
{
    public let filter: PHPickerFilter
    private let dataLoaders: [DataLoader]

    private init(
        filter: PHPickerFilter,
        dataLoaders: [DataLoader]
    )
    {
        self.filter = filter
        self.dataLoaders = dataLoaders
    }

    func makePublisher(results: [PHPickerResult]) -> AnyPublisher<[PhotoPickerData?], Never>
    {
        toAnyOf(dataLoaders: self.dataLoaders, results: results)
    }
}

// MARK: - PickerPattern Presets

extension PickerPattern
{
    public static let images = PickerPattern(filter: .images, dataLoaders: [.image])
    public static let videos = PickerPattern(filter: .videos, dataLoaders: [.video])
    public static let livePhotos = PickerPattern(filter: .livePhotos, dataLoaders: [.livePhoto])

    public static func any(of patterns: [PickerPattern]) -> PickerPattern
    {
        PickerPattern(
            filter: .any(of: patterns.map { $0.filter }),
            dataLoaders: patterns.reduce(into: []) { $0 += $1.dataLoaders }
        )
    }
}

// MARK: - Private

/// Loads picker data using `DatadataLoader`s.
private func toAnyOf(
    dataLoaders: [DataLoader],
    results: [PHPickerResult]
) -> AnyPublisher<[PhotoPickerData?], Never>
{
    typealias Publisher = AnyPublisher<PhotoPickerData?, Never>

    /// e.g. `[results.map(\.imagePublisher), results.map(\.videoPublisher)]`
    let publishersArray: [[Publisher]] = dataLoaders
        .map { pattern in
            results.map { result -> Publisher in
                pattern.publisher(result)
                    .map { Optional($0) }
                    .catch { _ in Just(nil) }
                    .eraseToAnyPublisher()
            }
        }

    /// e.g. `[ [Just(nil), Just(nil), ... (num of results)], [Just(nil), ...], ... (num of dataLoaders) ]`
    let initial: [Publisher] = [Publisher](
        repeating: Just(nil).eraseToAnyPublisher(),
        count: results.count
    )

    let publishers = publishersArray
        .reduce(into: initial) { (results: inout [Publisher], arrayOfPublishers: [Publisher]) in
            results = zip(results, arrayOfPublishers)
                .map { publisher1, publisher2 in
                    publisher1
                        .flatMap { (result1: PhotoPickerData?) -> Publisher in
                            if let result1 = result1 {
                                return Result.Publisher(result1).eraseToAnyPublisher()
                            }
                            else {
                                return publisher2.eraseToAnyPublisher()
                            }
                        }
                        .eraseToAnyPublisher()
                }
        }

    return Publishers.ZipMany(publishers)
        .eraseToAnyPublisher()
}
