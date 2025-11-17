import Foundation
import Alamofire
import Combine

public final class MGNetworkClient {
    public static var shared = MGNetworkClient()

    private let session: Session
    private let config: MGNetworkConfig
    private let decoder: JSONDecoder

    public init(config: MGNetworkConfig = .default,
                interceptor: RequestInterceptor? = MGMGTokenInterceptor.shared,
                eventMonitors: [EventMonitor] = [MGNetworkLogger.shared]) {
        self.config = config
        self.decoder = {
            let d = JSONDecoder()
            d.keyDecodingStrategy = .convertFromSnakeCase
            d.dateDecodingStrategy = .iso8601
            return d
        }()

        let urlCfg = URLSessionConfiguration.af.default
        urlCfg.timeoutIntervalForRequest = config.timeout
        urlCfg.headers = .default

        self.session = Session(configuration: urlCfg, interceptor: interceptor, eventMonitors: eventMonitors)
    }

    private func buildURL(_ path: String) -> URL {
        if path.contains("://"), let u = URL(string: path) { return u }
        return config.baseURL.appendingPathComponent(path)
    }

    public func mergedHeaders(staticHeaders: [String: String]? = nil,
                              requestHeaders: HTTPHeaders? = nil) -> HTTPHeaders {
        var result = HTTPHeaders()
        config.defaultHeaders.forEach { result.add($0) }
        if let sh = staticHeaders {
            for (k, v) in sh {
                result.update(name: k, value: v)
            }
        }
        if let rh = requestHeaders {
            for h in rh {
                result.update(name: h.name, value: h.value)
            }
        }
        return result
    }

    // Wrapped response expected: { code: Int, msg: String, data: T }
    public struct WrappedResponse<T: Codable>: Codable {
        public let code: Int
        public let msg: String?
        public let data: T?
    }

    @discardableResult
    public func request<T: Codable>(
        _ method: HTTPMethod = .get,
        _ path: String,
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = URLEncoding.default,
        staticHeaders: [String: String]? = nil,
        requestHeaders: HTTPHeaders? = nil
    ) async throws -> T {
        let url = buildURL(path)
        let headers = mergedHeaders(staticHeaders: staticHeaders, requestHeaders: requestHeaders)

        let req = session.request(url, method: method, parameters: parameters, encoding: encoding, headers: headers)
        let response = await req.serializingDecodable(WrappedResponse<T>.self, decoder: decoder).response

        if let afErr = response.error {
            throw MGAPIError.network(afErr)
        }
        guard let wrapped = response.value else {
            let status = response.response?.statusCode ?? -1
            throw MGAPIError.invalidResponse(statusCode: status, data: response.data)
        }
        if wrapped.code != 0 {
            throw MGAPIError.business(code: wrapped.code, message: wrapped.msg)
        }
        if let d = wrapped.data {
            return d
        } else {
            throw MGAPIError.custom(code: wrapped.code, message: wrapped.msg)
        }
    }

    public func publisher<T: Codable>(
        _ method: HTTPMethod = .get,
        _ path: String,
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
                Task {
                    do {
                        let v: T = try await self.request(method, path, parameters: parameters, encoding: encoding, staticHeaders: staticHeaders, requestHeaders: requestHeaders)
                        promise(.success(v))
                    } catch let apiError as MGAPIError {
                        promise(.failure(apiError))
                    } catch {
                        if let af = error as? AFError { promise(.failure(.network(af))) }
                        else if let dec = error as? DecodingError { promise(.failure(.decoding(dec))) }
                        else { promise(.failure(.custom(code: nil, message: error.localizedDescription))) }
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
