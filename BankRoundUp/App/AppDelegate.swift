import UIKit

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var mainNavigationController: UINavigationController?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        window = UIWindow(frame: UIScreen.main.bounds)

        if let window = window {
            let rootVC = RoundUpViewController()
            mainNavigationController = UINavigationController(rootViewController: rootVC)
            window.rootViewController = mainNavigationController
            window.makeKeyAndVisible()
        }

        return true
    }
}
