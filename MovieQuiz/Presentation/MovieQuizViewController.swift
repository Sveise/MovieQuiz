import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
  
    // MARK: - IB Outlets
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Private Properties

    lazy var alertPresenter = AlertPresenter(viewController: self)
    private let presenter = MovieQuizPresenter()
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewController = self
        showLoadingIndicator()
        presenter.questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        presenter.statisticService = StatisticService()
        presenter.questionFactory?.loadData()
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
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.red.cgColor
    }
    
    func startImageBorder() {
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = nil
        imageView.layer.cornerRadius = 20
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        presenter.didReceiveNextQuestion(question: question)
    }
    
    func buttonActive() {
        noButton.isEnabled = true
        yesButton.isEnabled = true
    }
    
    func buttonDisable() {
        noButton.isEnabled = false
        yesButton.isEnabled = false
    }
    
    func didLoadDataFromServer() {
        presenter.questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
        
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        imageView.layer.cornerRadius = 20
    }
    
    func showAnswerResult(isCorrect: Bool) {
        if isCorrect == true {
            hightlightImageBorder(isCorrectAnswer: true)
            imageView.layer.cornerRadius = 20
            presenter.correctAnswers += 1
            buttonDisable()
            showLoadingIndicator()
        }
        else {
            hightlightImageBorder(isCorrectAnswer: false)
            imageView.layer.cornerRadius = 20
            buttonDisable()
            showLoadingIndicator()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.presenter.showNextQuestionOrResults()
        }
    }

    // MARK: - Private Methods
        
    private func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    private func showNetworkError(message: String) {
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
    
    private struct ViewModel {
        let image: UIImage
        let question: String
        let questionNumber: String
    }
}

