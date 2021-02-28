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

    static let image = DataLoader { $0.imagePublisher.map { _PhotoPickerData.image($0) } }
    static let video = DataLoader { $0.videoPublisher.map { _PhotoPickerData.video($0) } }
    static let livePhoto = DataLoader { $0.livePhotoPublisher.map { _PhotoPickerData.livePhoto($0) } }
}
