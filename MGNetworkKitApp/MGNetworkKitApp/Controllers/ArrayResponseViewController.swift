import UIKit
import MGNetworkKit
import Combine

class ArrayResponseViewController: UITableViewController {
    private var items: [Product] = []
    private var bag = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Array Response"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Load", style: .plain, target: self, action: #selector(load))
    }

    @objc private func load() {
        Task {
            do {
                let req = ProductListRequest(page: 1, pageSize: 20)
                let arr: [Product] = try await ProductListRequest.request(req)
                self.items = arr
                DispatchQueue.main.async { self.tableView.reloadData() }
            } catch {
                print("Error:", error)
            }
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { items.count }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let p = items[indexPath.row]
        cell.textLabel?.text = "\(p.id) - \(p.name)"
        return cell
    }
}
