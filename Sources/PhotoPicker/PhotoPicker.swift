import SwiftUI
import PhotosUI
import Combine

/// `PHPickerViewController` wrapper for SwiftUI.
public struct PhotoPicker: UIViewControllerRepresentable
{
    @Binding
    public var datas: [PhotoPickerData?]

    private let configuration: PHPickerConfiguration
    private let pattern: PickerPattern

    @Environment(\.presentationMode)
    private var presentationMode

    public init(
        datas: Binding<[PhotoPickerData?]>,
        configuration: PHPickerConfiguration,
        pattern: PickerPattern
    )
    {
        self._datas = datas
        self.configuration = configuration
        self.pattern = pattern
    }

    public func makeUIViewController(context: Context) -> PHPickerViewController
    {
        let vc = PHPickerViewController(configuration: configuration)
        vc.delegate = context.coordinator
        return vc
    }

    public func updateUIViewController(
        _ uiViewController: PHPickerViewController,
        context: Context
    )
    {

    }

    public func makeCoordinator() -> Coordinator
    {
        Coordinator(self)
    }

    // MARK: - Coordinator

    public class Coordinator: PHPickerViewControllerDelegate
    {
        private let parent: PhotoPicker

        private var cancellables: Set<AnyCancellable> = .init()

        init(_ parent: PhotoPicker)
        {
            self.parent = parent
        }

        public func picker(
            _ picker: PHPickerViewController,
            didFinishPicking results: [PHPickerResult]
        )
        {
            if results.isEmpty {
                self.parent.presentationMode.wrappedValue.dismiss()
                self.parent.datas = []
                return
            }

            parent.pattern.makePublisher(results: results)
                .sink(receiveValue: { (datas: [PhotoPickerData?]) in
                    self.parent.presentationMode.wrappedValue.dismiss()
                    self.parent.datas = datas
                })
                .store(in: &cancellables)
        }
    }
}
