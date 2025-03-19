import UIKit

class AlertPresenter {
    weak var viewController: UIViewController?
    
    init(viewController: UIViewController?) {
        self.viewController = viewController
    }
    
    func show(result: AlertModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
            result.completion()
        }
    
       
        alert.addAction(action)
        
        viewController?.present(alert, animated: true, completion: nil)
    }
    
}
