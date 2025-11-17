import UIKit
import MGNetworkKit

class TokenRefreshViewController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Token Demo"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")

        let btn = UIBarButtonItem(title: "Request", style: .plain, target: self, action: #selector(requestAction))
        navigationItem.rightBarButtonItem = btn
    }

    @objc private func requestAction() {
//        Task {
//            do {
//                let req = UserInfoRequest(id: 1)
//                // Call generated API extension (hand-written in GeneratedAPIs/UserInfoRequest+API.swift)
//                let user: User = try await UserInfoRequest.request(req)
//                print("User:", user)
//                DispatchQueue.main.async { [weak self] in self?.tableView.reloadData() }
//            } catch {
//                print("Error:", error)
//            }
//        }
    }
}

