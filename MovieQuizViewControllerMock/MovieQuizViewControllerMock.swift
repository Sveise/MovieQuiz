import XCTest
@testable import MovieQuiz

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    func startImageBorder() {
        //nothing
    }
    
    func showAlert(result: MovieQuiz.AlertModel) {
        //nothing
    }
    
    func buttonActive() {
        //nothing
    }
    
    func buttonDisable() {
        //nothing
    }
    
    func show(quiz step: MovieQuiz.QuizStepViewModel) {
        //nothing
    }
    
    func hightlightImageBorder(isCorrectAnswer: Bool) {
        //nothing
    }
    
    func showLoadingIndicator() {
        //nothing
    }
    
    func hideLoadingIndicator() {
        //nothing
    }
    
    func showNetworkError(message: String) {
        //nothing
    }
}

final class MovieQuizPresenterTests: XCTestCase {
    func testPresenterConvertModel() throws {
        let viewControllerMock = MovieQuizViewControllerMock()
        let sut = MovieQuizPresenter(viewController: viewControllerMock)
        
        let emptyData = Data()
        let question = QuizQuestion(imageData: emptyData, text: "Question Text", correctAnswer: true)
        let viewModel = sut.convert(model: question)
        
        XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, "Question Text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
}
