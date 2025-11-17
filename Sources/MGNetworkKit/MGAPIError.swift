import Foundation
import Alamofire

public enum MGAPIError: Error, LocalizedError {
    case network(AFError)
    case decoding(Error)
    case invalidResponse(statusCode: Int, data: Data?)
    case business(code: Int, message: String?)
    case custom(code: Int?, message: String?)
    case cancelled

    public var errorDescription: String? {
        switch self {
        case .network(let af): return af.localizedDescription
        case .decoding(let e): return e.localizedDescription
        case .invalidResponse(let code, _): return "Invalid response: \(code)"
        case .business(let code, let msg): return "Business error \(code): \(msg ?? "")"
        case .custom(_, let msg): return msg
        case .cancelled: return "Request cancelled"
        }
    }
}
