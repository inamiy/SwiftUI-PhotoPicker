import Foundation
import PhotosUI
import Combine

// MARK: - loadObject

extension PHPickerResult
{
    func loadObject<T: NSItemProviderReading>(
        _ type: T.Type = T.self,
        completion: @escaping (Result<T, PhotoPickerError>) -> Void
    )
    {
        let provider = self.itemProvider

        guard provider.canLoadObject(ofClass: T.self) else {
            completion(.failure(.loadDataFailed(reason: "`canLoadObject(ofClass: \(T.self))` failed.")))
            return
        }

        provider.loadObject(ofClass: T.self) { image, error in
            if let image = image as? T {
                completion(.success(image))
            }
            else if let error = error {
                completion(.failure(.underlyingError(error)))
            }
            else {
                assertionFailure()
            }
        }
    }

    func objectPublisher<T: NSItemProviderReading>(
        _ type: T.Type = T.self
    ) -> AnyPublisher<T, PhotoPickerError>
    {
        Deferred {
            Future { completion in
                self.loadObject(type, completion: completion)
            }
        }
        .eraseToAnyPublisher()
    }
}

// MARK: - UIImage

extension PHPickerResult
{
    func loadImage(completion: @escaping (Result<UIImage, PhotoPickerError>) -> Void)
    {
        self.loadObject(completion: completion)
    }

    var imagePublisher: AnyPublisher<UIImage, PhotoPickerError>
    {
        self.objectPublisher()
    }
}

// MARK: - Video

extension PHPickerResult
{
    func loadVideo(completion: @escaping (Result<URL, PhotoPickerError>) -> Void)
    {
        let provider = self.itemProvider

        guard let typeIdentifier = provider.registeredTypeIdentifiers.first else {
            completion(.failure(.loadDataFailed(reason: "No `registeredTypeIdentifiers` while `loadVideo`.")))
            return
        }

        // NOTE: Required to call first.
        provider.loadFileRepresentation(forTypeIdentifier: typeIdentifier) { url, error in
            if let error = error {
                completion(.failure(.underlyingError(error)))
                return
            }

            provider.loadItem(forTypeIdentifier: typeIdentifier, options: nil) { (url, error) in
                if let url = url as? URL {
                    completion(.success(url))
                }
                else if let error = error {
                    completion(.failure(.underlyingError(error)))
                }
                else {
                    assertionFailure()
                }
            }
        }
    }

    var videoPublisher: AnyPublisher<URL, PhotoPickerError>
    {
        Deferred {
            Future(self.loadVideo(completion:))
        }
        .eraseToAnyPublisher()
    }
}

// MARK: - LivePhoto

extension PHPickerResult
{
    func getLivePhoto(completion: @escaping (Result<PHLivePhoto, PhotoPickerError>) -> Void)
    {
        self.loadObject(completion: completion)
    }

    var livePhotoPublisher: AnyPublisher<PHLivePhoto, PhotoPickerError>
    {
        self.objectPublisher()
    }
}
