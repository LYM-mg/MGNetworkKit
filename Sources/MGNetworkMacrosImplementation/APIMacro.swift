// Sources/NetworkMacrosImplementation/APIMacro.swift
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftCompilerPlugin

public struct APIMacro: ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        guard let structDecl = declaration.as(StructDeclSyntax.self) else { return [] }
        guard case let .argumentList(arguments) = node.arguments else { return [] }
        guard
            let pathExpr = arguments.first(where: { $0.label?.text == "path" })?.expression,
            let methodExpr = arguments.first(where: { $0.label?.text == "method" })?.expression
        else { return [] }
        let headersExpr = arguments.first(where: { $0.label?.text == "headers" })?.expression
        let typeName = structDecl.name.text
        let path = pathExpr.description.trimmingCharacters(in: .whitespacesAndNewlines)
        let method = methodExpr.description.trimmingCharacters(in: .whitespacesAndNewlines)
        let headers = (headersExpr?.description ?? "[:]").trimmingCharacters(in: .whitespacesAndNewlines)

        let ext = try ExtensionDeclSyntax(
            """
            extension \(raw: typeName) {
                @discardableResult
                public static func request<R: Codable>(
                    _ model: \(raw: typeName),
                    headers: HTTPHeaders? = nil
                ) async throws -> R {
                    let data = try JSONEncoder().encode(model)
                    let params = (try JSONSerialization.jsonObject(with: data) as? [String: Any]) ?? [:]
                    return try await MGNetworkClient.shared.request(
                        \(raw: method),
                        \(raw: path),
                        parameters: params,
                        encoding: \(raw: method) == .get ? URLEncoding.default : JSONEncoding.default,
                        staticHeaders: \(raw: headers),
                        requestHeaders: headers
                    )
                }

                public static func publisher<R: Codable>(
                    _ model: \(raw: typeName),
                    headers: HTTPHeaders? = nil
                ) -> AnyPublisher<R, MGAPIError> {
                    let data = try? JSONEncoder().encode(model)
                    let params = (data.flatMap { try? JSONSerialization.jsonObject(with: $0) as? [String: Any] }) ?? [:]
                    return MGNetworkClient.shared.publisher(
                        \(raw: method),
                        \(raw: path),
                        parameters: params,
                        encoding: \(raw: method) == .get ? URLEncoding.default : JSONEncoding.default,
                        staticHeaders: \(raw: headers),
                        requestHeaders: headers
                    )
                }
            }
            """
        )
        return [ext]
    }
}

// 注册插件
@main
struct APIMacroPlugin: CompilerPlugin {
    public let providingMacros: [Macro.Type] = [
        APIMacro.self,
    ]
}
