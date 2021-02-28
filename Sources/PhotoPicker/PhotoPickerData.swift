import UIKit
import PhotosUI

/// Extensible picker data Interface.
public protocol PhotoPickerData
{
    var image: UIImage? { get }
    var video: URL? { get }
    var livePhoto: PHLivePhoto? { get }
}

extension PhotoPickerData
{
    public var image: UIImage? { nil }
    public var video: URL? { nil }
    public var livePhoto: PHLivePhoto? { nil }
}
