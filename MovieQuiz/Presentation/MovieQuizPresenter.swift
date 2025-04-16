import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    var currentQuestion: QuizQuestion?
    var correctAnswers = 0
    var statisticService: StatisticServiceProtocol = StatisticService()
    var questionFactory: QuestionFactoryProtocol?
    weak var viewController: MovieQuizViewControllerProtocol?
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    // MARK: - Public Methods
    func yesButtonClicked() {
        didAdswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAdswer(isYes: false)
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(data: model.imageData) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async {
            self.viewController?.show(quiz: viewModel)
            self.viewController?.hideLoadingIndicator()
        }
    }
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        viewController?.showNetworkError(message: error.localizedDescription)
    }
    
    func showNextQuestionOrResults() {
        viewController?.startImageBorder()
        if self.isLastQuestion() {
            statisticService.store(gameResult: GameResult(correct: correctAnswers, total: self.questionsAmount, date: Date()))
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
                    self.resetQuestionIndex()
                    self.correctAnswers = 0
                    self.viewController?.buttonActive()
                    self.questionFactory?.loadData()
                    self.viewController?.hideLoadingIndicator()
                })
            viewController?.showAlert(result: viewModel)
        } else {
            switchToNextQuestion()
            questionFactory?.loadData()
            viewController?.buttonActive()
            viewController?.hideLoadingIndicator()
        }
    }
    
    // MARK: - Private Methods
    
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect == true {
            viewController?.hightlightImageBorder(isCorrectAnswer: true)
            correctAnswers += 1
            viewController?.buttonDisable()
            viewController?.showLoadingIndicator()
        }
        else {
            viewController?.hightlightImageBorder(isCorrectAnswer: false)
            viewController?.buttonDisable()
            viewController?.showLoadingIndicator()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showNextQuestionOrResults()
        }
    }
    
    private func didAdswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = isYes
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
}
