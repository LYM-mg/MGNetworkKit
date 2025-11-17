import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct MGAPIMacro: ExtensionMacro {
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        attachedTo declaration: some SwiftSyntax.DeclGroupSyntax,
        providingExtensionsOf type: some SwiftSyntax.TypeSyntaxProtocol,
        conformingTo protocols: [SwiftSyntax.TypeSyntax],
        in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.ExtensionDeclSyntax] {
        guard let structDecl = declaration.as(StructDeclSyntax.self) else { return [] }

        // 解析参数 path, method
            guard case let .argumentList(arguments) = node.arguments,
              let pathArg = arguments.first(where: { $0.label?.text == "path" })?.expression,
              let methodArg = arguments.first(where: { $0.label?.text == "method" })?.expression
        else { return [] }

        let typeName = structDecl.name.text
        let path = pathArg.description.trimmed
        let method = methodArg.description.trimmed

        return [
"""
extension \(raw: typeName) {

    @discardableResult
    public static func request(
        parameters: [String: Any]? = nil,
        headers: HTTPHeaders? = nil
    ) async throws -> \(raw: typeName) {
        try await NetworkClient.shared.request(
            method: \(method),
            path: \(path),
            parameters: parameters,
            encoding: \(method) == .get ? URLEncoding.default : JSONEncoding.default,
            headers: headers
        )
    }

    public static func publisher(
        parameters: [String: Any]? = nil,
        headers: HTTPHeaders? = nil
    ) -> AnyPublisher<\(typeName), APIError> {
        NetworkClient.shared.publisher(
            method: \(method),
            path: \(path),
            parameters: parameters,
            encoding: \(method) == .get ? URLEncoding.default : JSONEncoding.default,
            headers: headers
        )
    }
}
"""
        ].map { try! ExtensionDeclSyntax($0) }
    }
}
