import XCTest
@testable import MovieQuiz

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    func startImageBorder() {
        
    }
    
    func showAlert(result: MovieQuiz.AlertModel) {
        
    }
    
    func buttonActive() {
        
    }
    
    func buttonDisable() {
        
    }
    
    func show(quiz step: MovieQuiz.QuizStepViewModel) {
        
    }
    
    func hightlightImageBorder(isCorrectAnswer: Bool) {
        
    }
    
    func showLoadingIndicator() {
        
    }
    
    func hideLoadingIndicator() {
        
    }
    
    func showNetworkError(message: String) {
        
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
