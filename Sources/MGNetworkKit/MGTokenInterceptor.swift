import Foundation
import Alamofire

public final class MGMGTokenInterceptor: RequestInterceptor {
    public static let shared = MGMGTokenInterceptor()

    private let lock = NSLock()
    private var isRefreshing = false
    private var requestsToRetry: [(RetryResult) -> Void] = []

    public init() {}

    public func adapt(_ urlRequest: URLRequest,
               for session: Session,
               completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var req = urlRequest
        if let token = MGAuthStore.shared.accessToken {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        completion(.success(req))
    }

    public func retry(_ request: Request, for session: Session, dueTo error: Error,
                      completion: @escaping (RetryResult) -> Void) {
        if let response = request.response, response.statusCode == 401 {
            lock.lock()
            requestsToRetry.append(completion)
            if !isRefreshing {
                isRefreshing = true
                lock.unlock()
                Task {
                    let ok = await MGTokenRefresher.refresh()
                    lock.lock()
                    let completions = requestsToRetry
                    requestsToRetry.removeAll()
                    isRefreshing = false
                    lock.unlock()
                    completions.forEach { $0(ok ? .retry : .doNotRetry) }
                }
            } else {
                lock.unlock()
            }
        } else {
            completion(.doNotRetryWithError(error))
        }
    }
}
