import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    
    // MARK: - IB Outlets
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Private Properties
    private lazy var alertPresenter = AlertPresenter(viewController: self)
    private lazy var presenter = MovieQuizPresenter(viewController: self)
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = MovieQuizPresenter(viewController: self)
    }
    
    // MARK: - IB Actions
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    
    // MARK: - Public Methods
    
    func hightlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    
    func startImageBorder() {
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = nil
        imageView.layer.cornerRadius = 20
    }
    
    func buttonActive() {
        noButton.isEnabled = true
        yesButton.isEnabled = true
    }
    
    func buttonDisable() {
        noButton.isEnabled = false
        yesButton.isEnabled = false
    }
    
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        imageView.layer.cornerRadius = 20
    }
    
    func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    func showNetworkError(message: String) {
        let alertError = AlertModel(title: "Что-то пошло не так(", text: message, buttonText: "Попробовать еще раз") { [weak self] in
            guard let self else { return }
            self.showLoadingIndicator()
            self.presenter.resetQuestionIndex()
            self.presenter.correctAnswers = 0
            self.buttonActive()
            self.presenter.questionFactory?.loadData()
            self.hideLoadingIndicator()
        }
        alertPresenter.show(result: alertError)
    }
    
    func showAlert(result: AlertModel) {
        alertPresenter.show(result: result)
    }
    
    private struct ViewModel {
        let image: UIImage
        let question: String
        let questionNumber: String
    }
}
