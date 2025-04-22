import Foundation

protocol MovieQuizViewControllerProtocol: AnyObject {
    
    func show(quiz step: QuizStepViewModel)
    
    func hightlightImageBorder(isCorrectAnswer: Bool)
    
    func showLoadingIndicator()
    
    func hideLoadingIndicator()
    
    func showNetworkError(message: String)
    
    func buttonActive()
    
    func buttonDisable()
    
    func startImageBorder()
    
    func showAlert(result: AlertModel)
    
}
