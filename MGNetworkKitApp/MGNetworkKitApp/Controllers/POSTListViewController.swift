import UIKit
import Combine
import MGNetworkKit

class POSTListViewController: UITableViewController {
    private var pager: MGPager<Product>!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "POST Search"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        pager = MGPager<Product>(pageSize: 20) { page, pageSize in
            let req = ProductSearchRequest(keyword: "iPhone", category: "1", sort: "1", page: page, pageSize: pageSize)
            let arr: [Product] = try await ProductSearchRequest.request(req)
            return MGPageResult(list: arr, total: nil)
        }
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refreshAction), for: .valueChanged)
        refreshAction()
    }

    @objc private func refreshAction() { pager.refresh() }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { pager.items.count }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let p = pager.items[indexPath.row]
        cell.textLabel?.text = "\(p.id) - \(p.name)"
        return cell
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        if offsetY > contentHeight - scrollView.frame.height - 80 {
            pager.loadNext()
        }
    }
}
