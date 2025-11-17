import Foundation
import Alamofire
import Combine

public final class MGDownloadClient {
    public static let shared = MGDownloadClient()

    public init() {}

    public func download(url: URL) -> AnyPublisher<URL, MGAPIError> {
        let dst = DownloadRequest.suggestedDownloadDestination()
        return Deferred {
            Future { promise in
                AF.download(url, to: dst)
                    .downloadProgress { progress in
                        #if DEBUG
                        print("Download progress: \(progress.fractionCompleted)")
                        #endif
                    }
                    .response { resp in
                        if let url = resp.fileURL {
                            promise(.success(url))
                        } else if let error = resp.error {
                            if let af = error as? AFError { promise(.failure(.network(af))) }
                            else { promise(.failure(.custom(code: nil, message: error.localizedDescription))) }
                        } else {
                            promise(.failure(.custom(code: nil, message: "No file URL")))
                        }
                    }
            }
        }
        .eraseToAnyPublisher()
    }
}
