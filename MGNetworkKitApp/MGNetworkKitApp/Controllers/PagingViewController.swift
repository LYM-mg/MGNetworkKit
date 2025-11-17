//
//  PagingViewController.swift
//  MGNetworkKitApp
//
//  Created by Nicky on 2025/11/17.
//

import UIKit
import MGNetworkKit

class PagingViewController: UITableViewController {
    private var pager: MGPager<Product>!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Pager Demo"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
//        pager = MGPager<Product>(pageSize: 20) { page, pageSize in
//            let req = ProductListRequest(page: page, pageSize: pageSize)
//            let arr: [Product] = try await ProductListRequest.request(req)
//            return MGPageResult(list: arr, total: nil)
//        }
//        refreshControl = UIRefreshControl()
//        refreshControl?.addTarget(self, action: #selector(refreshAction), for: .valueChanged)
//        refreshAction()
//
//        // observe pager state via timer (simple)
//        Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { [weak self] _ in
//            DispatchQueue.main.async {
//                self?.tableView.reloadData()
//                self?.refreshControl?.endRefreshing()
//            }
//        }
//    }
//
//    @objc private func refreshAction() { pager.refresh() }
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
