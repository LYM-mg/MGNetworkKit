import Foundation
import Alamofire

public final class MGMGTokenInterceptor: RequestInterceptor, @unchecked Sendable {
    public static let shared = MGMGTokenInterceptor()

    private let lock = NSLock()
    private var isRefreshing = false
    private var requestsToRetry: [(RetryResult) -> Void] = []

    public init() {}

    public func adapt(_ urlRequest: URLRequest,
                      for session: Session,
                      completion: @escaping (Result<URLRequest, Error>) -> Void) {
//        Task {
//            var req = urlRequest
//            if let token = await MGAuthStore.shared.accessToken() {
//                req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//            }
//            completion(.success(req))
//        }
    }

    public func retry(_ request: Request, for session: Session, dueTo error: Error,
                      completion: @escaping (RetryResult) -> Void) {
        if let response = request.response, response.statusCode == 401 {
            let shouldRefresh: Bool = lock.withLock {
                requestsToRetry.append(completion)
                let s = !isRefreshing
                if s { isRefreshing = true }
                return s
            }

            if shouldRefresh {
                Task {
                    let ok = await MGTokenRefresher.refresh()
                    let completions: [(RetryResult) -> Void] = lock.withLock {
                        let c = requestsToRetry
                        requestsToRetry.removeAll()
                        isRefreshing = false
                        return c
                    }
                    completions.forEach { $0(ok ? .retry : .doNotRetry) }
                }
            }
        } else {
            completion(.doNotRetryWithError(error))
        }
    }
}
