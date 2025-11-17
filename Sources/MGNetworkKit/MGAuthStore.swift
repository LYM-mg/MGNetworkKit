import Foundation

public actor MGAuthStore {
    public static let shared = MGAuthStore()
    private var _accessToken: String?
    public init() {}
    public func setAccessToken(_ token: String?) { _accessToken = token }
    public func accessToken() -> String? { _accessToken }
}
