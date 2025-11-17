import UIKit
import MGNetworkKit

class DictResponseViewController: UITableViewController {
    private var user: User?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Dict Response"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Load", style: .plain, target: self, action: #selector(load))
    }

    @objc private func load() {
        Task {
            do {
                let req = UserInfoRequest(id: 1)
                let u: User = try await UserInfoRequest.request(req)
                self.user = u
                DispatchQueue.main.async { self.tableView.reloadData() }
            } catch {
                print("Error:", error)
            }
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { user == nil ? 0 : 1 }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if let u = user { cell.textLabel?.text = "\(u.id) - \(u.name)" }
        return cell
    }
}
