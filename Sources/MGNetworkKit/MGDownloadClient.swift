import Foundation
import Alamofire
import Combine

public final class MGDownloadClient {
    public static let shared = MGDownloadClient()

    public init() {}

    public func download(url: URL) -> AnyPublisher<URL, MGAPIError> {
        let dst = DownloadRequest.suggestedDownloadDestination()
        return AF.download(url, to: dst)
            .downloadProgress { progress in
                #if DEBUG
                print("Download progress: \(progress.fractionCompleted)")
                #endif
            }
            .publishResponse()
            .tryCompactMap { resp -> URL? in
                return resp.fileURL
            }
            .mapError { err in
                if let af = err.asAFError { return MGAPIError.network(af) }
                return MGAPIError.custom(code: nil, message: err.localizedDescription)
            }
            .eraseToAnyPublisher()
    }
}
