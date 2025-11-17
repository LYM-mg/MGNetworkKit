import Foundation
import Alamofire

public final class MGNetworkLogger: EventMonitor {
    public static let shared = MGNetworkLogger()
    public let queue = DispatchQueue(label: "MGNetworkLogger")

    public init() {}

    public func requestDidResume(_ request: Request) {
        #if DEBUG
        print("➡️ Request: \(request.description)")
        #endif
    }

    public func requestDidFinish(_ request: Request) {
        #if DEBUG
        print("✅ Finished: \(request.description)")
        #endif
    }

    public func request<Value>(_ request: DataRequest, didParseResponse response: DataResponse<Value, AFError>) {
        #if DEBUG
        let status = response.response?.statusCode ?? -1
        print("⬅️ Response status: \(status) for \(request.request?.url?.absoluteString ?? "")")
        if let data = response.data, let str = String(data: data, encoding: .utf8) {
            print("⬅️ Body: \(str)")
        }
        #endif
    }
}
