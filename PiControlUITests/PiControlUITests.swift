//
//  PiControlUITests.swift
//  PiControlUITests
//
//  Created by Julien Spronck on 11/02/2017.
//  Copyright © 2017 Julien Spronck. All rights reserved.
//

import XCTest

class PiControlTutorialUITests: XCTestCase {
    
    let app = XCUIApplication()
    
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        app.launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testTutorialSwipeLeftAndRight() {
        
        XCUIDevice.shared().orientation = .portrait
        
        let app = XCUIApplication()
        
        XCTAssertEqual(app.staticTexts.element(boundBy: 0).identifier, "TutorialTitle1")
        
        // let nextButton = app.buttons["Next"]
        
        let element = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element

        for j in 2...6 {
            element.swipeLeft()
            // print(app.staticTexts.element(boundBy: 0).label)
            // print(app.staticTexts.element(boundBy: 0).identifier)
            XCTAssertEqual(app.staticTexts.element(boundBy: 0).identifier, "TutorialTitle\(j)")
        }
        
        for j in 1...5 {
            element.swipeRight()
            // print(app.staticTexts.element(boundBy: 0).label)
            // print(app.staticTexts.element(boundBy: 0).identifier)
            XCTAssertEqual(app.staticTexts.element(boundBy: 0).identifier, "TutorialTitle\(6-j)")
        }
        
    }
    
    func testTutorialNextButton() {
        
        XCUIDevice.shared().orientation = .portrait
        
        let app = XCUIApplication()
        
        XCTAssertEqual(app.staticTexts.element(boundBy: 0).identifier, "TutorialTitle1")
        
        for j in 1...5 {
            app.buttons["TutorialNextButton\(j)"].tap()
            // print(app.staticTexts.element(boundBy: 0).label)
            // print(app.staticTexts.element(boundBy: 0).identifier)
            // XCTAssertEqual(app.staticTexts.element(boundBy: 0).identifier, "TutorialTitle\(j+1)")
        }
        
    }

    func testTutorialSkipTutorial() {
        
        XCUIDevice.shared().orientation = .portrait
        
        let app = XCUIApplication()
        
        app.buttons["Skip tutorial"].tap()
        
        XCTAssertEqual(app.tabBars.element.identifier, "Dashboard")
        
    }
    
    func testTutorialSkipTutorial2() {
        
        XCUIDevice.shared().orientation = .portrait
        
        let app = XCUIApplication()
        app.buttons["TutorialNextButton1"].tap()
        app.buttons["TutorialSkipButton2"].tap()
        
        XCTAssertEqual(app.tabBars.element.identifier, "Dashboard")
        
    }
    
    func testTutorialSkipTutorial3() {
        
        XCUIDevice.shared().orientation = .portrait
        
        let app = XCUIApplication()
        app.buttons["TutorialNextButton1"].tap()
        app.buttons["TutorialNextButton2"].tap()
        app.buttons["TutorialSkipButton3"].tap()
        
        XCTAssertEqual(app.tabBars.element.identifier, "Dashboard")
        
    }
    
    func testTutorialSkipTutorial4() {
        
        XCUIDevice.shared().orientation = .portrait
        
        let app = XCUIApplication()
        app.buttons["TutorialNextButton1"].tap()
        app.buttons["TutorialNextButton2"].tap()
        app.buttons["TutorialNextButton3"].tap()
        app.buttons["TutorialSkipButton4"].tap()
        
        XCTAssertEqual(app.tabBars.element.identifier, "Dashboard")
        
    }
    
    func testTutorialSkipTutorial5() {
        
        XCUIDevice.shared().orientation = .portrait
        
        let app = XCUIApplication()
        app.buttons["TutorialNextButton1"].tap()
        app.buttons["TutorialNextButton2"].tap()
        app.buttons["TutorialNextButton3"].tap()
        app.buttons["TutorialNextButton4"].tap()
        app.buttons["TutorialSkipButton5"].tap()
        
        XCTAssertEqual(app.tabBars.element.identifier, "Dashboard")
        
    }

    func testTutorialGetStarted() {
        
        XCUIDevice.shared().orientation = .portrait
        
        let app = XCUIApplication()
        app.buttons["TutorialNextButton1"].tap()
        app.buttons["TutorialNextButton2"].tap()
        app.buttons["TutorialNextButton3"].tap()
        app.buttons["TutorialNextButton4"].tap()
        app.buttons["TutorialNextButton5"].tap()
        app.buttons["Get Started"].tap()
        
        XCTAssertEqual(app.tabBars.element.identifier, "Dashboard")
        
    }
    
    func testTutorialAddServer() {
        XCUIDevice.shared().orientation = .portrait
        
        let app = XCUIApplication()
        app.buttons["TutorialNextButton1"].tap()
        app.buttons["TutorialNextButton2"].tap()
        
        let anyNameYouLikeTextField = app.textFields["Any name you like"]
        anyNameYouLikeTextField.tap()
        anyNameYouLikeTextField.typeText("NewServer")
        
        let httpYourserverLocalTextField = app.textFields["http://yourserver.local"]
        httpYourserverLocalTextField.tap()
        httpYourserverLocalTextField.typeText("\r")
        httpYourserverLocalTextField.typeText("http://NewServer.local")
        
        let eG1234TextField = app.textFields["e.g. 1234"]
        eG1234TextField.tap()
        eG1234TextField.typeText("\r")
        eG1234TextField.typeText("1234")
        app.typeText("\r")
        
    }
    
}
