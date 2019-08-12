import UIKit

extension UIViewController {

    public func showAlert(
        title: String,
        message: String,
        cancelText: String,
        onCancel: (() -> ())? = nil) {

        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert)
        let cancelAction = UIAlertAction(
            title: cancelText,
            style: .cancel,
            handler: { _ in onCancel?() })
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
}
