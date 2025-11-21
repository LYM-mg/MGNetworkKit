// Sources/NetworkMacrosImplementation/APIMacro.swift
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftCompilerPlugin
import Foundation
import Alamofire

public struct APIMacro: ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        // Ensure attached to a struct/enum/class
        guard let structDecl = declaration.as(StructDeclSyntax.self) else {
            return []
        }

        // Parse argument list
        guard case let .argumentList(arguments) = node.arguments else { return [] }

        func exprForLabel(_ labels: [String]) -> ExprSyntax? {
            for l in labels {
                if let item = arguments.first(where: { $0.label?.text == l }) {
                    return item.expression
                }
            }
            return nil
        }

        func stringLiteralValue(forLabel label: String) -> String? {
            guard let expr = arguments.first(where: { $0.label?.text == label })?.expression else { return nil }
            if let str = expr.as(StringLiteralExprSyntax.self) {
                // join segments and strip quotes
                return str.segments.map(\.description).joined().trimmingCharacters(in: .whitespacesAndNewlines).trimmingCharacters(in: CharacterSet(charactersIn: "\""))
            }
            return nil
        }

        // Accept both "path" and "url" just in case
        guard let pathExpr = exprForLabel(["path", "url"]) else { return [] }
        // method should be an expression of type HTTPMethod (e.g. .get or .post)
        guard let methodExpr = exprForLabel(["method"]) else { return [] }
        // header(s) can be labeled "header" or "headers"
        let headersExpr = exprForLabel(["headers", "header"])

        let typeName = structDecl.identifier.text

        // Prepare trimmed textual representations for raw injection
        let pathText = pathExpr.description.trimmingCharacters(in: .whitespacesAndNewlines)
        let methodText = methodExpr.description.trimmingCharacters(in: .whitespacesAndNewlines)
        let headersText = headersExpr?.description.trimmingCharacters(in: .whitespacesAndNewlines) ?? "[:]" // default empty dict

        // Build the extension - note: we inject method and headers as raw expressions (no quotes)
        let ext = try ExtensionDeclSyntax(
            """
            extension \(raw: typeName) {
                @discardableResult
                public static func request<R: Codable & Sendable>(
                    _ model: \(raw: typeName),
                    headers: HTTPHeaders? = nil
                ) async throws -> R {
                    let data = try JSONEncoder().encode(model)
                    let params = (try JSONSerialization.jsonObject(with: data) as? [String: Any]) ?? [:]
                    return try await MGNetworkClient.shared.request(
                        \(raw: pathText),
                        \(raw: methodText),
                        parameters: params,
                        encoding: {
                            // evaluate method at runtime (works for `.get`, `.post`, `HTTPMethod.get`, etc.)
                            let m: HTTPMethod = \(raw: methodText)
                            return m == .get ? URLEncoding.default : JSONEncoding.default
                        }(),
                        staticHeaders: \(raw: headersText),
                        requestHeaders: headers
                    )
                }

                public static func publisher<R: Codable & Sendable>(
                    _ model: \(raw: typeName),
                    headers: HTTPHeaders? = nil
                ) -> AnyPublisher<R, MGAPIError> {
                    let data = try? JSONEncoder().encode(model)
                    let params = (data.flatMap { try? JSONSerialization.jsonObject(with: $0) as? [String: Any] }) ?? [:]
                    return MGNetworkClient.shared.publisher(
                        \(raw: pathText),
                        \(raw: methodText),
                        parameters: params,
                        encoding: {
                            let m: HTTPMethod = \(raw: methodText)
                            return m == .get ? URLEncoding.default : JSONEncoding.default
                        }(),
                        staticHeaders: \(raw: headersText),
                        requestHeaders: headers
                    )
                }
            }
            """
        )

        return [ext]
    }
    
    /*
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        // 解析 annotation 的参数
        let arguments = node.argumentList
        func extractString(_ label: String) -> String? {
            arguments.first { $0.label?.text == label }?
                .expression.as(StringLiteralExprSyntax.self)?
                .segments.first?.description.replacingOccurrences(of: "\"", with: "")
        }
        
        func extractDictionary(_ label: String) -> ExprSyntax? {
            arguments.first { $0.label?.text == label }?.expression
        }
        
        let pathText = extractString("path") ?? ""
        let methodText = extractString("method") ?? ""
        let headers = extractDictionary("header") // 是一个 ExprSyntax，保留原样
        
        // 目标类型名
        guard let typeName = type.as(SimpleTypeIdentifierSyntax.self)?.name.text else {
            throw MacroError.message("@API must attach to a class/struct")
        }
        guard let structDecl = declaration.as(StructDeclSyntax.self) else { return [] }
        guard case let .argumentList(arguments) = node.arguments else { return [] }
        guard
            let pathExpr = arguments.first(where: { $0.label?.text == "path" })?.expression,
            let methodExpr = arguments.first(where: { $0.label?.text == "method" })?.expression
        else { return [] }
        let typeName = structDecl.name.text
        let method = methodExpr.trimmedDescription
        let path = pathExpr.trimmedDescription
        let headers = arguments.first(where: { $0.label?.text == "headers" })?.expression.trimmedDescription ?? "[:]"

        let m: HTTPMethod = \(raw: methodText)
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
                        \(raw: pathText),   // ⭐ 第 1 个参数必须是 path
                        \(raw: m),     // ⭐ 第 2 个参数才是 method
                        parameters: params,
                        encoding: {
                            return m == .get ? URLEncoding.default : JSONEncoding.default
                        }(),
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
                        \(raw: pathText),
                        \(raw: m),
                        parameters: params,
                        encoding: {
                            return m == .get ? URLEncoding.default : JSONEncoding.default
                        }(),
                        staticHeaders: \(raw: headers),
                        requestHeaders: headers
                    )
                }
            }
            """
        )
        return [ext]
    }
     */
}

// 注册插件
@main
struct APIMacroPlugin: CompilerPlugin {
    public let providingMacros: [Macro.Type] = [
        APIMacro.self,
        MGAPIMacro.self,
    ]
}
