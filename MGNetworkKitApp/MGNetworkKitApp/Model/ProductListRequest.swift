//
//  21e33.swift
//  MGNetworkKitApp
//
//  Created by Nicky on 2025/11/17.
//

import UIKit
import MGNetworkKit
import MGNetworkMacros
import Alamofire
import Combine

@MGAPI(path: "/product/list", method: .post)
public struct ProductListRequest: Codable {
    let page: Int
    let pageSize: Int
}

struct ProductListResponse: Codable, Sendable {
    let code: Int
    let msg: String
    let data: [Product]
}

public struct Product: Codable, Sendable { let id: Int; let name: String }

@API(path: "/user/info", method: .get)
public struct UserInfoRequest: Codable {
    var id: Int
}

//@LYMAPI(path: "/product/search", method: .get)
public struct User: Codable, Sendable {
    let id: Int
    let name: String
}

//@MGAPI(path: "/product/search", method: .get)
public struct ProductSearchRequest: Codable {
    let keyword: String
    let category: String?
    let sort: String?
    let page: Int
    let pageSize: Int
}

//extension UserInfoRequest {
//    @discardableResult
//    public static func request(_ model: UserInfoRequest? = nil, headers: HTTPHeaders? = nil) async throws -> User {
//        let encoding: ParameterEncoding = URLEncoding.default  // ParameterEncoding.queryString
//        let params: Parameters? = {
//            guard let m = model else { return nil }
//            if let d = try? JSONEncoder().encode(m),
//               let obj = try? JSONSerialization.jsonObject(with: d),
//               let dict = obj as? [String: Any] { return dict }
//            return nil
//        }()
//        return try await MGNetworkClient.shared.request("/user/info", .get, parameters: params, encoding: encoding, staticHeaders: nil, requestHeaders: headers)
//    }
//
//    public static func publisher(_ model: UserInfoRequest? = nil, headers: HTTPHeaders? = nil) -> AnyPublisher<User, MGAPIError> {
//        let encoding: ParameterEncoding = URLEncoding.default
//        let params: Parameters? = {
//            guard let m = model else { return nil }
//            if let d = try? JSONEncoder().encode(m),
//               let obj = try? JSONSerialization.jsonObject(with: d),
//               let dict = obj as? [String: Any] { return dict }
//            return nil
//        }()
//        return MGNetworkClient.shared.publisher("/user/info", .get,  parameters: params, encoding: encoding, staticHeaders: nil, requestHeaders: headers)
//    }
//}
//
//// Generated extension for ProductListRequest (GET list)
//extension ProductListRequest {
//    @discardableResult
//    public static func request(_ model: ProductListRequest? = nil, headers: HTTPHeaders? = nil) async throws -> [Product] {
//        let encoding: ParameterEncoding = URLEncoding.default
//        let params: Parameters? = {
//            guard let m = model else { return nil }
//            if let d = try? JSONEncoder().encode(m),
//               let obj = try? JSONSerialization.jsonObject(with: d),
//               let dict = obj as? [String: Any] { return dict }
//            return nil
//        }()
//        return try await MGNetworkClient.shared.request("/product/list", .get,  parameters: params, encoding: encoding, staticHeaders: nil, requestHeaders: headers)
//    }
//
//    public static func publisher(_ model: ProductListRequest? = nil, headers: HTTPHeaders? = nil) -> AnyPublisher<[Product], MGAPIError> {
//        let encoding: ParameterEncoding = URLEncoding.default
//        let params: Parameters? = {
//            guard let m = model else { return nil }
//            if let d = try? JSONEncoder().encode(m),
//               let obj = try? JSONSerialization.jsonObject(with: d),
//               let dict = obj as? [String: Any] { return dict }
//            return nil
//        }()
//        return MGNetworkClient.shared.publisher("/product/list", .get, parameters: params, encoding: encoding, staticHeaders: nil, requestHeaders: headers)
//    }
//}
//
//extension ProductSearchRequest {
//    @discardableResult
//    public static func request(_ model: ProductSearchRequest? = nil, headers: HTTPHeaders? = nil) async throws -> [Product] {
//        let encoding: ParameterEncoding = JSONEncoding.default
//        let params: Parameters? = {
//            guard let m = model else { return nil }
//            if let d = try? JSONEncoder().encode(m),
//               let obj = try? JSONSerialization.jsonObject(with: d),
//               let dict = obj as? [String: Any] { return dict }
//            return nil
//        }()
//        return try await MGNetworkClient.shared.request("/product/search", .post,  parameters: params, encoding: encoding, staticHeaders: nil, requestHeaders: headers)
//    }
//
//    public static func publisher(_ model: ProductSearchRequest? = nil, headers: HTTPHeaders? = nil) -> AnyPublisher<[Product], MGAPIError> {
//        let encoding: ParameterEncoding = JSONEncoding.default
//        let params: Parameters? = {
//            guard let m = model else { return nil }
//            if let d = try? JSONEncoder().encode(m),
//               let obj = try? JSONSerialization.jsonObject(with: d),
//               let dict = obj as? [String: Any] { return dict }
//            return nil
//        }()
//        return MGNetworkClient.shared.publisher("/product/search", .post,  parameters: params, encoding: encoding, staticHeaders: nil, requestHeaders: headers)
//    }
//}
