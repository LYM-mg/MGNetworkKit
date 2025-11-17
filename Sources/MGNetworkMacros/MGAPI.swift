import Foundation
import Alamofire

import SwiftSyntaxMacros
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftCompilerPlugin

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

@attached(extension, names: named(request), named(publisher))
public macro API2(
    path: String,
    method: HTTPMethod = .get,
    headers: [String: String] = [:]
) = #externalMacro(module: "MGNetworkMacros", type: "MGAPIMemberMacro")
