import Foundation

public enum MGTokenRefresher {
    public static func refresh() async -> Bool {
        try? await Task.sleep(nanoseconds: 300_000_000)
        await MGAuthStore.shared.setAccessToken("token_\(Int(Date().timeIntervalSince1970))")
        return true
    }
}
