import Foundation
import SwiftSyntaxMacros
import Alamofire

@attached(extension, names: named(request), named(publisher))
public macro MGAPI(
    path: String,
    method: HTTPMethod = .get,
    headers: [String: String] = [:]
) = #externalMacro(module: "MGNetworkMacrosImplementation", type: "MGAPIMacro")
