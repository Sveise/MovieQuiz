import XCTest

final class MovieQuizUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        app = XCUIApplication()
        app.launch()
        
        continueAfterFailure = false

    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        app.terminate()
        app = nil
    }

//    @MainActor
//    func testExample() throws {
//        let app = XCUIApplication()
//        app.launch()
//    }
    
    func testYesButton() {
        sleep(3)
        let firstPoster = app.images["Poster"]
        let indexLabel = app.staticTexts["Index"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["Yes"].tap()
      
        sleep(3)
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        app.buttons["No"].tap()
        
        XCTAssertEqual(indexLabel.label, "2/10")
        //XCTAssertTrue(firstPoster.exists)
        //XCTAssertTrue(secondPoster.exists)
        XCTAssertFalse(firstPosterData == secondPosterData)
        
        sleep(2)
        app.buttons["No"].tap()
        
        sleep(2)
        app.buttons["Yes"].tap()
        
        sleep(2)
        app.buttons["No"].tap()
        
        sleep(2)
        app.buttons["Yes"].tap()
        
        sleep(2)
        app.buttons["No"].tap()
        
        sleep(2)
        app.buttons["Yes"].tap()
        
        sleep(2)
        app.buttons["No"].tap()
        
        sleep(2)
        app.buttons["Yes"].tap()
        sleep(5)
        
        let alert = app.alerts["Этот раунд окончен!"]
        XCTAssertTrue(alert.exists)
        XCTAssertEqual(alert.label, "Этот раунд окончен!")
        XCTAssertEqual(alert.buttons.firstMatch.label, "Сыграть ещё раз")
        
        alert.tap()
        
        
    }
    
}
