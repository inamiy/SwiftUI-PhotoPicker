import UIKit
import Photos

enum _PhotoPickerData: PhotoPickerData
{
    case image(UIImage)
    case video(URL?)
    case livePhoto(PHLivePhoto)

    var image: UIImage?
    {
        guard case let .image(value) = self else { return nil }
        return value
    }

    var video: URL?
    {
        guard case let .video(value) = self else { return nil }
        return value
    }

    var livePhoto: PHLivePhoto?
    {
        guard case let .livePhoto(value) = self else { return nil }
        return value
    }
}
