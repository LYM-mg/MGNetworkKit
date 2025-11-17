import Foundation
import Alamofire

public struct MGNetworkConfig {
    public var baseURL: URL
    public var defaultHeaders: HTTPHeaders
    public var timeout: TimeInterval

    public init(baseURL: URL,
                defaultHeaders: HTTPHeaders = .default,
                timeout: TimeInterval = 60) {
        self.baseURL = baseURL
        self.defaultHeaders = defaultHeaders
        self.timeout = timeout
    }

    public static var `default`: MGNetworkConfig {
        MGNetworkConfig(
            baseURL: URL(string: "https://api.example.com")!,
            defaultHeaders: HTTPHeaders([HTTPHeader(name: "Accept", value: "application/json")]),
            timeout: 60
        )
    }
}
