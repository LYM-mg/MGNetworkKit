import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftCompilerPlugin

public struct MGAPIMacro: ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        guard let structDecl = declaration.as(StructDeclSyntax.self) else { return [] }
        
        // 解析参数 path, method
        guard case let .argumentList(arguments) = node.arguments,
              let pathArg = arguments.first(where: { $0.label?.text == "path" })?.expression,
              let methodArg = arguments.first(where: { $0.label?.text == "method" })?.expression
        else { return [] }
        
        let typeName = structDecl.name.text
        let path = pathArg.description.trimmingCharacters(in: .whitespacesAndNewlines)
        let method = methodArg.description.trimmingCharacters(in: .whitespacesAndNewlines)
        let headersExpr = arguments.first(where: { $0.label?.text == "headers" })?.expression.description.trimmingCharacters(in: .whitespacesAndNewlines) ?? "[:]"

        return [
"""
extension \(raw: typeName) {
@discardableResult
public static func request<R: Codable>(
    _ model: \(raw: typeName),
    headers: HTTPHeaders? = nil
) async throws -> R {
    let jsonData = try JSONEncoder().encode(model)
    let params = (try JSONSerialization.jsonObject(with: jsonData) as? [String: Any]) ?? [:]
    return try await MGNetworkClient.shared.request(
        \(raw: method),
        \(raw: path),
        parameters: params,
        encoding: \(raw: method) == .get ? URLEncoding.default : JSONEncoding.default,
        staticHeaders: \(raw: headersExpr),
        requestHeaders: headers
    )
}

public static func publisher<R: Codable>(
    _ model: \(raw: typeName),
    headers: HTTPHeaders? = nil
) -> AnyPublisher<R, MGAPIError> {
    let jsonData = try? JSONEncoder().encode(model)
    let params = (jsonData.flatMap { try? JSONSerialization.jsonObject(with: $0) as? [String: Any] }) ?? [:]
    return MGNetworkClient.shared.publisher(
        \(raw: method),
        \(raw: path),
        parameters: params,
        encoding: \(raw: method) == .get ? URLEncoding.default : JSONEncoding.default,
        staticHeaders: \(raw: headersExpr),
        requestHeaders: headers
    )
}
}
"""
        ].map { try! ExtensionDeclSyntax($0) }
    }
    
    
//    public static func expansion(
//        of node: SwiftSyntax.AttributeSyntax,
//        attachedTo declaration: some SwiftSyntax.DeclGroupSyntax,
//        providingExtensionsOf type: some SwiftSyntax.TypeSyntaxProtocol,
//        conformingTo protocols: [SwiftSyntax.TypeSyntax],
//        in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.ExtensionDeclSyntax] {
//            guard let structDecl = declaration.as(StructDeclSyntax.self) else { return [] }
//            
//            // 解析参数 path, method
//            guard case let .argumentList(arguments) = node.arguments,
//                  let pathArg = arguments.first(where: { $0.label?.text == "path" })?.expression,
//                  let methodArg = arguments.first(where: { $0.label?.text == "method" })?.expression
//            else { return [] }
//            
//            let typeName = structDecl.name.text
//            let path = pathArg.description.trimmingCharacters(in: .whitespacesAndNewlines)
//            let method = methodArg.description.trimmingCharacters(in: .whitespacesAndNewlines)
//            let headersExpr = arguments.first(where: { $0.label?.text == "headers" })?.expression.description.trimmingCharacters(in: .whitespacesAndNewlines) ?? "[:]"
//
//            return [
//"""
//extension \(raw: typeName) {
//    @discardableResult
//    public static func request<R: Codable>(
//        _ model: \(raw: typeName),
//        headers: HTTPHeaders? = nil
//    ) async throws -> R {
//        let jsonData = try JSONEncoder().encode(model)
//        let params = (try JSONSerialization.jsonObject(with: jsonData) as? [String: Any]) ?? [:]
//        return try await MGNetworkClient.shared.request(
//            \(raw: method),
//            \(raw: path),
//            parameters: params,
//            encoding: \(raw: method) == .get ? URLEncoding.default : JSONEncoding.default,
//            staticHeaders: \(raw: headersExpr),
//            requestHeaders: headers
//        )
//    }
//
//    public static func publisher<R: Codable>(
//        _ model: \(raw: typeName),
//        headers: HTTPHeaders? = nil
//    ) -> AnyPublisher<R, MGAPIError> {
//        let jsonData = try? JSONEncoder().encode(model)
//        let params = (jsonData.flatMap { try? JSONSerialization.jsonObject(with: $0) as? [String: Any] }) ?? [:]
//        return MGNetworkClient.shared.publisher(
//            \(raw: method),
//            \(raw: path),
//            parameters: params,
//            encoding: \(raw: method) == .get ? URLEncoding.default : JSONEncoding.default,
//            staticHeaders: \(raw: headersExpr),
//            requestHeaders: headers
//        )
//    }
//}
//"""
//            ].map { try! ExtensionDeclSyntax($0) }
//        }
}
