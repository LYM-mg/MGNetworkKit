import Foundation
import Alamofire

@attached(extension, names: named(request), named(publisher))
public macro MGAPI(
    path: String,
    method: HTTPMethod = .get,
    headers: [String: String] = [:]
) = #externalMacro(module: "MGNetworkMacrosImplementation", type: "MGAPIMacro")

@attached(extension, names: named(request), named(publisher))
public macro API(
    path: String,
    method: HTTPMethod = .get,
    headers: [String: String] = [:]
) = #externalMacro(module: "MGNetworkMacrosImplementation", type: "APIMacro")
