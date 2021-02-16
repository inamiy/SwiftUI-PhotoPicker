import PhotosUI
import Combine

/// Simple wrapper for async data-loading publisher to change its output type to `PhotoPickerData`.
struct DataLoader
{
    let publisher: (PHPickerResult) -> AnyPublisher<PhotoPickerData, PhotoPickerError>

    public init<P>(
        _ publisher: @escaping (PHPickerResult) -> P
    ) where
        P: Publisher, P.Output: PhotoPickerData, P.Failure == PhotoPickerError
    {
        self.publisher = { publisher($0).map { $0 as PhotoPickerData }.eraseToAnyPublisher() }
    }

    static let image = DataLoader(\.imagePublisher)
    static let video = DataLoader(\.videoPublisher)
    static let livePhoto = DataLoader(\.livePhotoPublisher)
}
