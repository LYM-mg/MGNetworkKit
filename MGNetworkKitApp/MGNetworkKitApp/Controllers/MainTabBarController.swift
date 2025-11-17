import UIKit

class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let getVC = GETListViewController()
        getVC.tabBarItem = UITabBarItem(title: "GET List", image: nil, selectedImage: nil)

        let postVC = POSTListViewController()
        postVC.tabBarItem = UITabBarItem(title: "POST List", image: nil, selectedImage: nil)

        let pagingVC = PagingViewController()
        pagingVC.tabBarItem = UITabBarItem(title: "Paging", image: nil, selectedImage: nil)

        let tokenVC = TokenRefreshViewController()
        tokenVC.tabBarItem = UITabBarItem(title: "Token", image: nil, selectedImage: nil)

        let retryVC = RetryViewController()
        retryVC.tabBarItem = UITabBarItem(title: "Retry", image: nil, selectedImage: nil)

        let dictVC = DictResponseViewController()
        dictVC.tabBarItem = UITabBarItem(title: "Dict", image: nil, selectedImage: nil)

        let arrVC = ArrayResponseViewController()
        arrVC.tabBarItem = UITabBarItem(title: "Array", image: nil, selectedImage: nil)

        let wrappedVC = WrappedResponseViewController()
        wrappedVC.tabBarItem = UITabBarItem(title: "Wrapped", image: nil, selectedImage: nil)

        viewControllers = [UINavigationController(rootViewController: getVC),
                           UINavigationController(rootViewController: postVC),
                           UINavigationController(rootViewController: pagingVC),
                           UINavigationController(rootViewController: tokenVC),
                           UINavigationController(rootViewController: retryVC),
                           UINavigationController(rootViewController: dictVC),
                           UINavigationController(rootViewController: arrVC),
                           UINavigationController(rootViewController: wrappedVC)]
    }
}
