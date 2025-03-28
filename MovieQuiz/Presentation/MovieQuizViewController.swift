import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {

    // MARK: - IB Outlets
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Private Properties
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private lazy var alertPresenter = AlertPresenter(viewController: self)
    private var statisticService: StatisticServiceProtocol = StatisticService()
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        showLoadingIndicator()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        statisticService = StatisticService()
        questionFactory?.loadData()
    }
 
    // MARK: - IB Actions
     @IBAction private func noButtonClicked(_ sender: UIButton) {
         guard let currentQuestion = currentQuestion else {
             return
         }
         let givenAnswer = false
         showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
         
     }
     
     @IBAction private func yesButtonClicked(_ sender: UIButton) {
         guard let currentQuestion = currentQuestion else {
             return
         }
         let givenAnswer = true
         showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
     }

    // MARK: - Public Methods
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async {
            self.show(quiz: viewModel)
        }
    }

    // MARK: - Private Methods
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(image: UIImage(data: model.image) ?? UIImage(), question: model.text, questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        imageView.layer.cornerRadius = 20
    }
    
    private func showAnswerResult(isCorrect: Bool) {
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
        if currentQuestionIndex == questionsAmount - 1 {
            statisticService.store(gameResult: GameResult(correct: correctAnswers, total: questionsAmount, date: Date()))
            let viewModel = AlertModel(
                title: "Этот раунд окончен!",
                text: """
                Ваш результат: \(correctAnswers)/\(questionsAmount)
                Количество сыграных квизов: \(statisticService.gamesCount)
                Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) \(statisticService.bestGame.date.dateTimeString)
                Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
                """,
                buttonText: "Сыграть ещё раз",
                completion: {
                                [weak self] in
                                guard let self else { return }
                                self.currentQuestionIndex = 0
                                self.correctAnswers = 0
                                self.noButton.isEnabled = true
                                self.yesButton.isEnabled = true
                                self.questionFactory?.loadData()
                                self.hideLoadingIndicator()
                            })
            alertPresenter.show(result: viewModel)
        } else {
            self.currentQuestionIndex += 1
            self.questionFactory?.loadData()
            noButton.isEnabled = true
            yesButton.isEnabled = true
            self.hideLoadingIndicator()
        }
    }
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    private func showNetworkError(message: String) {
        let alertError = AlertModel(title: "Что-то пошло не так(", text: message, buttonText: "Попробовать еще раз") { [weak self] in
            guard let self else { return }
            self.showLoadingIndicator()
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            self.noButton.isEnabled = true
            self.yesButton.isEnabled = true
            self.questionFactory?.loadData()
            self.hideLoadingIndicator()
        }
        alertPresenter.show(result: alertError)
    }
    
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    private struct ViewModel {
        let image: UIImage
        let question: String
        let questionNumber: String
    }
}

