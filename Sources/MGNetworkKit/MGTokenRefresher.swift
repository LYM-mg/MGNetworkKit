import Foundation

public final class MGTokenRefresher {
    public static func refresh() async -> Bool {
        try? await Task.sleep(nanoseconds: 300_000_000)
        MGAuthStore.shared.accessToken = "token_\(Int(Date().timeIntervalSince1970))"
        return true
    }
}
