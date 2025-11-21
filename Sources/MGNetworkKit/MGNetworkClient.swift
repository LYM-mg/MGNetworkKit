import Foundation
import Alamofire
import Combine

public final class MGNetworkClient: @unchecked Sendable {
    
    // MARK: - Shared instance
    public static let shared = MGNetworkClient()
    
    // MARK: - Properties
    public private(set) var config: MGNetworkConfig
    private var session: Session
    private let decoder: JSONDecoder
    
    // MARK: - Init
    public init(config: MGNetworkConfig = .init(baseURL: URL(string: "https://api.example.com")!),
                interceptor: RequestInterceptor? = MGTokenInterceptor.shared,
                eventMonitors: [EventMonitor] = [MGNetworkLogger.shared]) {
        
        self.config = config
        self.decoder = JSONDecoder()
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.decoder.dateDecodingStrategy = .iso8601
        
        let urlCfg = URLSessionConfiguration.af.default
        urlCfg.timeoutIntervalForRequest = config.timeout
        urlCfg.headers = .default
        
        self.session = Session(configuration: urlCfg, interceptor: interceptor, eventMonitors: eventMonitors)
    }
    
    // MARK: - Configure
    public func configure(_ block: (inout MGNetworkConfig) -> Void) {
        block(&config)
        let urlCfg = URLSessionConfiguration.af.default
        urlCfg.timeoutIntervalForRequest = config.timeout
        urlCfg.headers = .default
        self.session = Session(configuration: urlCfg, interceptor: MGTokenInterceptor.shared, eventMonitors: [MGNetworkLogger.shared])
    }
    
    // MARK: - Helpers
    private func buildURL(_ path: String) -> URL {
        if path.contains("://"), let u = URL(string: path) { return u }
        return config.baseURL.appendingPathComponent(path)
    }
    
    private func mergedHeaders(staticHeaders: [String: String]? = nil,
                               requestHeaders: HTTPHeaders? = nil) -> HTTPHeaders {
        var result = HTTPHeaders()
        config.defaultHeaders.forEach { result.add($0) }
        if let sh = staticHeaders {
            for (k, v) in sh { result.update(name: k, value: v) }
        }
        if let rh = requestHeaders {
            for h in rh { result.update(name: h.name, value: h.value) }
        }
        return result
    }

    // Wrapped response expected: { code: Int, msg: String, data: T }
    public struct WrappedResponse<T: Codable & Sendable>: Codable, Sendable {
        public let code: Int
        public let msg: String?
        public let data: T?
    }

    @discardableResult
    public func request<T: Codable & Sendable>(
        _ path: String,
        _ method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = URLEncoding.default,
        staticHeaders: [String: String]? = nil,
        requestHeaders: HTTPHeaders? = nil
    ) async throws -> T {
        let url = buildURL(path)
        let headers = mergedHeaders(staticHeaders: staticHeaders, requestHeaders: requestHeaders)

        let req = session.request(url, method: method, parameters: parameters, encoding: encoding, headers: headers)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        let response = await req.serializingDecodable(WrappedResponse<T>.self, decoder: decoder).response

        if let afErr = response.error { throw MGAPIError.network(afErr) }
        guard let wrapped = response.value else {
            let status = response.response?.statusCode ?? -1
            throw MGAPIError.invalidResponse(statusCode: status, data: response.data)
        }
        if wrapped.code != 0 { throw MGAPIError.business(code: wrapped.code, message: wrapped.msg) }
        if let d = wrapped.data { return d }
        throw MGAPIError.custom(code: wrapped.code, message: wrapped.msg)
    }

    public func publisher<T: Codable & Sendable>(
        _ path: String,
        _ method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = URLEncoding.default,
        staticHeaders: [String: String]? = nil,
        requestHeaders: HTTPHeaders? = nil
    ) -> AnyPublisher<T, MGAPIError> {
        Deferred {
            Future { [weak self] promise in
                guard let self = self else {
                    promise(.failure(.custom(code: nil, message: "MGNetworkClient deallocated")))
                    return
                }
                let url = self.buildURL(path)
                let headers = self.mergedHeaders(staticHeaders: staticHeaders, requestHeaders: requestHeaders)
                let req = self.session.request(url, method: method, parameters: parameters, encoding: encoding, headers: headers)

                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                decoder.dateDecodingStrategy = .iso8601
                req.responseDecodable(of: WrappedResponse<T>.self, decoder: decoder) { response in
                    if let afErr = response.error {
                        promise(.failure(.network(afErr)))
                        return
                    }
                    guard let wrapped = response.value else {
                        let status = response.response?.statusCode ?? -1
                        promise(.failure(.invalidResponse(statusCode: status, data: response.data)))
                        return
                    }
                    if wrapped.code != 0 {
                        promise(.failure(.business(code: wrapped.code, message: wrapped.msg)))
                        return
                    }
                    if let d = wrapped.data {
                        promise(.success(d))
                    } else {
                        promise(.failure(.custom(code: wrapped.code, message: wrapped.msg)))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
