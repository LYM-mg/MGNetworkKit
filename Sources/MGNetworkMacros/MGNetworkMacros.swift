import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftCompilerPlugin

public struct MGAPIMemberMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        
        // 1. 解析参数
        guard let argumentList = node.arguments?.as(LabeledExprListSyntax.self) else {
            return []
        }

        var pathValue: String?
        var methodValue: String?
        var headersValue: String = "[:]" // 默认值

        for argument in argumentList {
            let label = argument.label?.description.trimmingCharacters(in: .whitespacesAndNewlines)
            let expression = argument.expression.description

            switch label {
            case "path":
                // path: 表达式是 String 字面量，例如 "/api/..."
                pathValue = expression
            case "method":
                // method: 表达式是 String 字面量，例如 "get"
                // 宏中需要将其转换为 HTTPMethod.get
                methodValue = expression
            case "headers":
                // headers: 表达式是字典字面量，例如 ["key": "value"]
                headersValue = expression
            default:
                continue
            }
        }
        
        // 确保关键参数存在
        guard let path = pathValue, let methodString = methodValue else {
            return []
        }
        
        // 将方法字符串转换为 Alamofire/HTTPMethod 语法
        let afMethod = ".\(methodString.replacingOccurrences(of: "\"", with: ""))" // e.g., .get

        // 2. 构造 request 方法
        let requestMethod = """
        @discardableResult
        public func request<T: Codable & Sendable>(
            parameters: Parameters? = nil,
            encoding: ParameterEncoding = URLEncoding.default,
            requestHeaders: HTTPHeaders? = nil
        ) async throws -> T {
            let staticHeaders = \(headersValue)
            return try await MGNetworkClient.shared.request(
                \(path),
                \(afMethod),
                parameters: parameters,
                encoding: encoding,
                staticHeaders: staticHeaders,
                requestHeaders: requestHeaders
            )
        }
        """

        // 3. 构造 publisher 方法
        let publisherMethod = """
        public func publisher<T: Codable & Sendable>(
            parameters: Parameters? = nil,
            encoding: ParameterEncoding = URLEncoding.default,
            requestHeaders: HTTPHeaders? = nil
        ) -> AnyPublisher<T, MGAPIError> {
            let staticHeaders = \(headersValue)
            return MGNetworkClient.shared.publisher(
                \(path),
                \(afMethod),
                parameters: parameters,
                encoding: encoding,
                staticHeaders: staticHeaders,
                requestHeaders: requestHeaders
            )
        }
        """

        return [
            DeclSyntax(stringLiteral: requestMethod),
            DeclSyntax(stringLiteral: publisherMethod)
        ]
    }
}

// 注册插件
struct NetworkMacroPlugin1: CompilerPlugin {
    public let providingMacros: [Macro.Type] = [
        MGAPIMemberMacro.self
    ]
}
