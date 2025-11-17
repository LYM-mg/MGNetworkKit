import UIKit
import MGNetworkKit

class WrappedResponseViewController: UITableViewController {
    private var items: [Product] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Wrapped Response"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Load", style: .plain, target: self, action: #selector(load))
    }

    @objc private func load() {
//        Task {
//            do {
//                // Example: API returns {code:0, msg:"", data: [ ... ] }
//                let req = ProductListRequest(page: 1, pageSize: 20)
//                let arr: [Product] = try await ProductListRequest.request(req)
//                self.items = arr
//                DispatchQueue.main.async { self.tableView.reloadData() }
//            } catch {
//                print("Error:", error)
//            }
//        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { items.count }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let p = items[indexPath.row]
        cell.textLabel?.text = "\(p.id) - \(p.name)"
        return cell
    }
}
