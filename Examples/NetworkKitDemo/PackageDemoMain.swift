import Foundation
import MGNetworkKit
import MGNetworkMacros
import Alamofire
import Combine

@MGAPI(path: "/product/search", method: .get, headers: ["X-Feature": "1"])
struct ProductSearchRequest: Codable {
    let keyword: String
    let category: String?
    let sort: String?
    var page: Int
    var pageSize: Int
}

struct Product: Codable {
    let id: Int
    let name: String
}

struct ProductListResponse: Codable {
    let list: [Product]
    let total: Int?
}

var bag = Set<AnyCancellable>()

@main
struct DemoApp {
    static func main() async {
        print("Demo started")
        let pager = MGPager<Product>(pageSize: 20) { page, pageSize in
            let model = ProductSearchRequest(keyword: "iPhone", category: nil, sort: nil, page: page, pageSize: pageSize)
            let resp: ProductListResponse = try await ProductSearchRequest.request(model)
            return MGPageResult(list: resp.list, total: resp.total)
        }

        pager.refresh()
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        print("MGPager state after refresh:", pager.state)
        pager.loadNext()
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        print("MGPager items count:", pager.items.count)
        print("Demo finished")
    }
}
