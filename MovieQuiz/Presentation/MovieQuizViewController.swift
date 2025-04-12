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
    private var correctAnswers = 0
    private var questionFactory: QuestionFactoryProtocol?

    private lazy var alertPresenter = AlertPresenter(viewController: self)
    private var statisticService: StatisticServiceProtocol = StatisticService()
    private let presenter = MovieQuizPresenter()
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewController = self
        showLoadingIndicator()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        statisticService = StatisticService()
        questionFactory?.loadData()
    }
    
    // MARK: - IB Actions
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.currentQuestion = presenter.currentQuestion
       presenter.noButtonClicked()
    }
        
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.currentQuestion = presenter.currentQuestion
       presenter.yesButtonClicked()
    }
    
    // MARK: - Public Methods
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else {
            return
        }
        presenter.currentQuestion = question
        let viewModel = presenter.convert(model: question)
        DispatchQueue.main.async {
            self.show(quiz: viewModel)
            self.hideLoadingIndicator()
        }
    }
    
    func didLoadDataFromServer() {
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    // MARK: - Private Methods
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        imageView.layer.cornerRadius = 20
    }
    
    func showAnswerResult(isCorrect: Bool) {
        if isCorrect == true {
            imageView.layer.masksToBounds = true
            imageView.layer.borderWidth = 8
            imageView.layer.borderColor = UIColor.ypGreen.cgColor
            imageView.layer.cornerRadius = 20
            correctAnswers += 1
            noButton.isEnabled = false
            yesButton.isEnabled = false
            showLoadingIndicator()
        }
        else {
            imageView.layer.masksToBounds = true
            imageView.layer.borderWidth = 8
            imageView.layer.borderColor = UIColor.ypRed.cgColor
            imageView.layer.cornerRadius = 20
            noButton.isEnabled = false
            yesButton.isEnabled = false
            showLoadingIndicator()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showNextQuestionOrResults()
        }
    }
    
    private func showNextQuestionOrResults() {
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = nil
        imageView.layer.cornerRadius = 20
        if presenter.isLastQuestion() {
            statisticService.store(gameResult: GameResult(correct: correctAnswers, total: presenter.questionsAmount, date: Date()))
            let viewModel = AlertModel(
                title: "Этот раунд окончен!",
                text: """
                Ваш результат: \(correctAnswers)/\(presenter.questionsAmount)
                Количество сыграных квизов: \(statisticService.gamesCount)
                Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) \(statisticService.bestGame.date.dateTimeString)
                Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
                """,
                buttonText: "Сыграть ещё раз",
                completion: {
                    [weak self] in
                    guard let self else { return }
                    self.presenter.resetQuestionIndex()
                    self.correctAnswers = 0
                    self.noButton.isEnabled = true
                    self.yesButton.isEnabled = true
                    self.questionFactory?.loadData()
                    self.hideLoadingIndicator()
                })
            alertPresenter.show(result: viewModel)
        } else {
            presenter.switchToNextQuestion()
            questionFactory?.loadData()
            noButton.isEnabled = true
            yesButton.isEnabled = true
            hideLoadingIndicator()
        }
    }
    
    private func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    private func showNetworkError(message: String) {
        let alertError = AlertModel(title: "Что-то пошло не так(", text: message, buttonText: "Попробовать еще раз") { [weak self] in
            guard let self else { return }
            self.showLoadingIndicator()
            self.presenter.resetQuestionIndex()
            self.correctAnswers = 0
            self.noButton.isEnabled = true
            self.yesButton.isEnabled = true
            self.questionFactory?.loadData()
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

