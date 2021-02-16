# SwiftUI-PhotoPicker
iOS 14 PHPickerViewController wrapper for SwiftUI with data loader support.

## How to Use

```swift
struct ContentView: View
{
    @State
    private var datas: [PhotoPickerData?] = []

    @State
    private var isShowingPicker = false

    var body: some View
    {
        VStack(spacing: 40) {
            Button("Select Image") {
                self.isShowingPicker = true
            }

            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(), count: 2)) {
                    ForEach(datas.enumerated().map { ($0, $1) }, id: \.0) { i, data in
                        if let image = data?.image {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                        }
                        else if let videoURL = data?.video {
                            VideoPlayer(player: AVPlayer(url: videoURL))
                                .frame(width: 200, height: 200, alignment: .center)
                        }
                        else if let livePhoto = data?.livePhoto {
                            LivePhotoView(livePhoto: .constant(livePhoto))
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $isShowingPicker) {
            PhotoPicker(
                datas: $datas,
                configuration: pickerConfig,
                pattern: pickerPattern
            )
        }
    }
}

private let pickerPattern: PickerPattern = .any(of: [.images, .videos, .livePhotos])

private let pickerConfig: PHPickerConfiguration = {
    var config = PHPickerConfiguration()
    config.filter = pickerPattern.filter
    config.selectionLimit = 0
    config.preferredAssetRepresentationMode = .current // required for video
    return config
}()
```

## Example

<img src="https://user-images.githubusercontent.com/138476/108079568-4c358e80-70b2-11eb-893d-4ea86970a562.gif">

See [Examples](Examples) for more information.

## License

[MIT](LICENSE)
