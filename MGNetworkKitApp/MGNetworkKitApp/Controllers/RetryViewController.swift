import UIKit
import MGNetworkKit

class RetryViewController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Retry Demo"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        // add a button to simulate a failing call then retry
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Try", style: .plain, target: self, action: #selector(tryAction))
    }

    @objc private func tryAction() {
//        Task {
//            do {
//                // Simulate call (you can provide an endpoint that sometimes fails)
//                let req = ProductListRequest(page: 1, pageSize: 10)
//                let arr: [Product] = try await ProductListRequest.request(req)
//                print("Success count:", arr.count)
//            } catch {
//                print("First try failed:", error)
//                // Optionally retry manually
//                do {
//                    let req = ProductListRequest(page: 1, pageSize: 10)
//                    let arr: [Product] = try await ProductListRequest.request(req)
//                    print("Retry success:", arr.count)
//                } catch {
//                    print("Retry failed:", error)
//                }
//            }
//        }
    }
}
