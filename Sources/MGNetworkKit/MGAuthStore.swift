import Foundation

public final class MGAuthStore {
    public static let shared = MGAuthStore()
    public var accessToken: String?
    private init() {}
}
