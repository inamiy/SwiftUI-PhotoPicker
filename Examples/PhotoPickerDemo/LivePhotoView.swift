import SwiftUI
import PhotosUI

struct LivePhotoView: UIViewRepresentable
{
    @Binding
    var livePhoto: PHLivePhoto?

    func makeUIView(context: Context) -> PHLivePhotoView
    {
        PHLivePhotoView()
    }

    func updateUIView(_ lpView: PHLivePhotoView, context: Context)
    {
        lpView.livePhoto = livePhoto
    }
}
