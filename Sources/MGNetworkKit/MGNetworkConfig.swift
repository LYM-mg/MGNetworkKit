import Foundation
import Alamofire

public struct MGNetworkConfig {
    public var baseURL: URL
    public var defaultHeaders: HTTPHeaders
    public var timeout: TimeInterval
    public var logEnabled: Bool

    public init(
        baseURL: URL,
        defaultHeaders: HTTPHeaders = .default,
        timeout: TimeInterval = 60,
        logEnabled: Bool = false
    ) {
        self.baseURL = baseURL
        self.defaultHeaders = defaultHeaders
        self.timeout = timeout
        self.logEnabled = logEnabled
    }
}
