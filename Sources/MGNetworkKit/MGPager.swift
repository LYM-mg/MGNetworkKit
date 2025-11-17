import Foundation
import Combine

public struct MGPageResult<Item: Codable>: Codable {
    public let list: [Item]
    public let total: Int?

    public init(list: [Item], total: Int? = nil) {
        self.list = list
        self.total = total
    }
}

public enum MGPagerState<Item> {
    case initial
    case refreshing
    case loadingMore
    case finished([Item])
    case failed(Error)
}

public final class MGPager<Item: Codable> {
    public private(set) var items: [Item] = []
    public private(set) var page: Int = 1
    public private(set) var pageSize: Int
    public private(set) var noMoreData: Bool = false
    public private(set) var state: MGPagerState<Item> = .initial

    private var loadClosureAsync: (_ page: Int, _ pageSize: Int) async throws -> MGPageResult<Item>
    private var cancellables = Set<AnyCancellable>()

    public init(pageSize: Int = 20,
                loadClosureAsync: @escaping (_ page: Int, _ pageSize: Int) async throws -> MGPageResult<Item>) {
        self.pageSize = pageSize
        self.loadClosureAsync = loadClosureAsync
    }

    public func reset() {
        page = 1
        noMoreData = false
        items.removeAll()
        state = .initial
    }

    public func refresh() {
        Task {
            await performLoad(isRefresh: true)
        }
    }

    public func loadNext() {
        guard !noMoreData else { return }
        Task {
            await performLoad(isRefresh: false)
        }
    }

    private func setState(_ s: MGPagerState<Item>) {
        DispatchQueue.main.async {
            self.state = s
        }
    }

    private func performLoad(isRefresh: Bool) async {
        if isRefresh {
            page = 1
            noMoreData = false
            setState(.refreshing)
        } else {
            page += 1
            setState(.loadingMore)
        }

        do {
            let result = try await loadClosureAsync(page, pageSize)
            if page == 1 {
                items = result.list
            } else {
                items += result.list
            }
            noMoreData = result.list.isEmpty
            setState(.finished(items))
        } catch {
            if page > 1 {
                page -= 1
            }
            setState(.failed(error))
        }
    }
}
