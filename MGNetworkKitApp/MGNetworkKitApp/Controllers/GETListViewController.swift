import UIKit
import Combine
import MGNetworkKit

class GETListViewController: UITableViewController {
    private var items: [Product] = []
    private var pager: MGPager<Product>!
    private var bag = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "GET List"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")

//        pager = MGPager<Product>(pageSize: 20) { page, pageSize in
//            let req = ProductListRequest(page: page, pageSize: pageSize)
//            // This uses GeneratedAPIs/ProductListRequest+API.swift
//            let products: [Product] = try await ProductListRequest.request(req)
//            return MGPageResult(list: products, total: nil)
//        }
//
//        // Observe pager state by periodic polling (or you can add Combine publisher wrapper)
//        // Simpler: use timer to update UI on state changes
//        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { [weak self] _ in
//            guard let self = self else { return }
//            DispatchQueue.main.async {
//                self.items = self.pager.items
//                self.tableView.reloadData()
//                self.refreshControl?.endRefreshing()
//            }
//        }
//
//        refreshControl = UIRefreshControl()
//        refreshControl?.addTarget(self, action: #selector(refreshAction), for: .valueChanged)
//        refreshAction()
//    }
//
//    @objc private func refreshAction() {
//        pager.refresh()
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { pager.items.count }
//
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
//        let p = pager.items[indexPath.row]
//        cell.textLabel?.text = "\(p.id) - \(p.name)"
//        return cell
//    }
//
//    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let offsetY = scrollView.contentOffset.y
//        let contentHeight = scrollView.contentSize.height
//        if offsetY > contentHeight - scrollView.frame.height - 80 {
//            pager.loadNext()
//        }
    }
}
