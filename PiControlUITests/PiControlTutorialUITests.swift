//
//  PiControlUITests.swift
//  PiControlUITests
//
//  Created by Julien Spronck on 11/02/2017.
//  Copyright © 2017 Julien Spronck. All rights reserved.
//

// In order to run these tests successfully, you need to delete the user data in UserDefaults (you can do that by uncommenting the right lines in AppDelegate.application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool

import XCTest

extension XCUIElement {
    /**
     Deletes any current text in the field
     */
    func clearText() -> Void {
        guard let stringValue = self.value as? String else {
            return
        }
        
        let deleteString = stringValue.characters.map { _ in XCUIKeyboardKeyDelete }.joined(separator: "")
        
        self.typeText(deleteString)
    }
}

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
        XCUIDevice.shared().orientation = .portrait
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testTutorialSwipeLeftAndRight() {
        // Swipe through all tutorial pages and back and check that the user landed on the right pages
        
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
        // Go through all tutorial pages and back and check that the user landed on the right pages
        
        XCTAssertEqual(app.staticTexts.element(boundBy: 0).identifier, "TutorialTitle1")
        
        for j in 1...5 {
            app.buttons["TutorialNextButton\(j)"].tap()
            // print(app.staticTexts.element(boundBy: 0).label)
            // print(app.staticTexts.element(boundBy: 0).identifier)
            // XCTAssertEqual(app.staticTexts.element(boundBy: 0).identifier, "TutorialTitle\(j+1)")
        }
        
    }

    func testTutorialSkipTutorial() {
        
        app.buttons["Skip tutorial"].tap()
        XCTAssertEqual(app.tabBars.element.identifier, "Dashboard")
        
    }
    
    func testTutorialSkipTutorial2() {
        
        app.buttons["TutorialNextButton1"].tap()
        app.buttons["TutorialSkipButton2"].tap()
        XCTAssertEqual(app.tabBars.element.identifier, "Dashboard")
        
    }
    
    func testTutorialSkipTutorial3() {

        app.buttons["TutorialNextButton1"].tap()
        app.buttons["TutorialNextButton2"].tap()
        app.buttons["TutorialSkipButton3"].tap()
        XCTAssertEqual(app.tabBars.element.identifier, "Dashboard")
        
    }
    
    func testTutorialSkipTutorial4() {

        app.buttons["TutorialNextButton1"].tap()
        app.buttons["TutorialNextButton2"].tap()
        app.buttons["TutorialNextButton3"].tap()
        app.buttons["TutorialSkipButton4"].tap()
        XCTAssertEqual(app.tabBars.element.identifier, "Dashboard")
        
    }
    
    func testTutorialSkipTutorial5() {

        app.buttons["TutorialNextButton1"].tap()
        app.buttons["TutorialNextButton2"].tap()
        app.buttons["TutorialNextButton3"].tap()
        app.buttons["TutorialNextButton4"].tap()
        app.buttons["TutorialSkipButton5"].tap()
        
        XCTAssertEqual(app.tabBars.element.identifier, "Dashboard")
        
    }

    func testTutorialGetStarted() {

        app.buttons["TutorialNextButton1"].tap()
        app.buttons["TutorialNextButton2"].tap()
        app.buttons["TutorialNextButton3"].tap()
        app.buttons["TutorialNextButton4"].tap()
        app.buttons["TutorialNextButton5"].tap()
        app.buttons["Get Started"].tap()
        
        XCTAssertEqual(app.tabBars.element.identifier, "Dashboard")
        
    }
    
    func testTutorialAddServer() {
        // First add a server by tapping in textfields, typing the info and tapping the "Add Server" button.
        // Then add a server with the keyboard only.
        // In the second case, there should be an Error alert (adding twice the same server info).

        app.buttons["TutorialNextButton1"].tap()
        app.buttons["TutorialNextButton2"].tap()
        
        let ServerNameTextField = app.textFields["TutorialServerNameTextField"]
        ServerNameTextField.tap()
        ServerNameTextField.typeText("NewServer")
        
        let HostAddressTextField = app.textFields["TutorialHostAddressTextField"]
        HostAddressTextField.tap()
        HostAddressTextField.typeText("http://NewServer.local")
        
        let PortNumberTextField = app.textFields["TutorialPortNumberTextField"]
        PortNumberTextField.tap()
        PortNumberTextField.typeText("1234")
        
        app.buttons["TutorialAddServerButton"].tap()
        
        let label = app.staticTexts.element(boundBy: 0)
        let rightTitle = NSPredicate(format: "identifier == 'TutorialTitle4'")
        expectation(for: rightTitle, evaluatedWith: label, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        
        XCTAssertEqual(label.identifier, "TutorialTitle4")
        
        if app.alerts["Error"].exists {
            app.alerts["Error"].buttons["OK"].tap()
        }
        
        label.swipeRight()
        
        ServerNameTextField.tap()
        ServerNameTextField.typeText("\r")
        HostAddressTextField.typeText("\r")
        PortNumberTextField.typeText("\r")
        
        let error = app.alerts["Error"]
        XCTAssertTrue(error.exists)
        XCTAssertEqual(error.staticTexts.element(boundBy: 1).label, "Server not added because it already exists in your settings.")
        
        error.buttons["OK"].tap()
        
    }
    
    func testTutorialEmptyServerName() {
        // When trying to add a server but the server name is empty, there should be an error
        
        app.buttons["TutorialNextButton1"].tap()
        app.buttons["TutorialNextButton2"].tap()
        
        let ServerNameTextField = app.textFields["TutorialServerNameTextField"]
        ServerNameTextField.tap()
        ServerNameTextField.typeText("\r")
        
        let HostAddressTextField = app.textFields["TutorialHostAddressTextField"]
        HostAddressTextField.typeText("http://NewServer.local\r")
        
        let PortNumberTextField = app.textFields["TutorialPortNumberTextField"]
        PortNumberTextField.typeText("1234")
        
        app.buttons["TutorialAddServerButton"].tap()
        
        let label = app.staticTexts.element(boundBy: 0)
        XCTAssertEqual(label.identifier, "TutorialTitle3")
        
        let error = app.alerts["Error"]
        XCTAssertTrue(error.exists)
        XCTAssertEqual(error.staticTexts.element(boundBy: 1).label, "Server name, host address and port number cannot be empty.")
        
        error.buttons["OK"].tap()
        
    }
    
    func testTutorialEmptyHostAddress() {
        // When trying to add a server but the hostAddress is empty, there should be an error
        
        app.buttons["TutorialNextButton1"].tap()
        app.buttons["TutorialNextButton2"].tap()
        
        let ServerNameTextField = app.textFields["TutorialServerNameTextField"]
        ServerNameTextField.tap()
        ServerNameTextField.typeText("NewServer\r")
        
        let HostAddressTextField = app.textFields["TutorialHostAddressTextField"]
        HostAddressTextField.typeText("\r")
        
        let PortNumberTextField = app.textFields["TutorialPortNumberTextField"]
        PortNumberTextField.typeText("1234")
        
        app.buttons["TutorialAddServerButton"].tap()
        
        let label = app.staticTexts.element(boundBy: 0)
        XCTAssertEqual(label.identifier, "TutorialTitle3")
        
        let error = app.alerts["Error"]
        XCTAssertTrue(error.exists)
        XCTAssertEqual(error.staticTexts.element(boundBy: 1).label, "Server name, host address and port number cannot be empty.")
        
        error.buttons["OK"].tap()
        
    }
 
    func testTutorialEmptyPortNumber() {
        // When trying to add a server but the server name is empty, there should be an error
        
        app.buttons["TutorialNextButton1"].tap()
        app.buttons["TutorialNextButton2"].tap()
        
        let ServerNameTextField = app.textFields["TutorialServerNameTextField"]
        ServerNameTextField.tap()
        ServerNameTextField.typeText("NewServer\r")
        
        let HostAddressTextField = app.textFields["TutorialHostAddressTextField"]
        HostAddressTextField.typeText("http://NewServer.local\r")
        
        app.buttons["TutorialAddServerButton"].tap()
        
        let label = app.staticTexts.element(boundBy: 0)
        XCTAssertEqual(label.identifier, "TutorialTitle3")
        
        let error = app.alerts["Error"]
        XCTAssertTrue(error.exists)
        XCTAssertEqual(error.staticTexts.element(boundBy: 1).label, "The port number must be a 4-digit integer.")
        
        error.buttons["OK"].tap()
        
    }
    
    func testTutorialPortNumberWrongNumberOfDigits() {
        // When typing wrong number of digits in port number text field
        
        app.buttons["TutorialNextButton1"].tap()
        app.buttons["TutorialNextButton2"].tap()
        
        let ServerNameTextField = app.textFields["TutorialServerNameTextField"]
        ServerNameTextField.tap()
        ServerNameTextField.typeText("NewServer\r")
        
        let HostAddressTextField = app.textFields["TutorialHostAddressTextField"]
        HostAddressTextField.typeText("http://NewServer.local\r")

        let PortNumberTextField = app.textFields["TutorialPortNumberTextField"]
        PortNumberTextField.typeText("123")
        
        app.buttons["TutorialAddServerButton"].tap()
        
        let label = app.staticTexts.element(boundBy: 0)
        XCTAssertEqual(label.identifier, "TutorialTitle3")
        
        let error = app.alerts["Error"]
        XCTAssertTrue(error.exists)
        XCTAssertEqual(error.staticTexts.element(boundBy: 1).label, "The port number must be a 4-digit integer.")
        error.buttons["OK"].tap()

        XCTAssertFalse(error.exists)
        
        PortNumberTextField.tap()
        PortNumberTextField.typeText("45")
        
        app.buttons["TutorialAddServerButton"].tap()
        
        XCTAssertTrue(error.exists)
        XCTAssertEqual(error.staticTexts.element(boundBy: 1).label, "The port number must be a 4-digit integer.")
        
        error.buttons["OK"].tap()
        
    }
 
    func testTutorialPortNumberWrongType() {
        // When typing letters in the port number text field instead of digits
        
        app.buttons["TutorialNextButton1"].tap()
        app.buttons["TutorialNextButton2"].tap()
        
        let ServerNameTextField = app.textFields["TutorialServerNameTextField"]
        ServerNameTextField.tap()
        ServerNameTextField.typeText("NewServer")
        
        let PortNumberTextField = app.textFields["TutorialPortNumberTextField"]
        PortNumberTextField.tap()
        PortNumberTextField.typeText("a")
        

        let error = app.alerts["Error"]
//        let exists = NSPredicate(format: "exists == true")
//        expectation(for: exists, evaluatedWith: error, handler: nil)
//        ServerNameTextField.tap()
//        waitForExpectations(timeout: 5, handler: nil)
//        
        XCTAssertTrue(error.exists)
        XCTAssertEqual(error.staticTexts.element(boundBy: 1).label, "The port number must be a 4-digit integer.")
//        error.buttons["OK"].tap()
        
    }

    func testTutorialAddButtonWithoutAddingAServer() {
        // First add a button by tapping in textfields, typing the info and tapping the "Add Button" button.
        // Then add a server with the keyboard only.
        
        app.buttons["TutorialNextButton1"].tap()
        app.buttons["TutorialNextButton2"].tap()
        app.buttons["TutorialNextButton3"].tap()
        app.buttons["TutorialNextButton4"].tap()
        
        let tutorialButtonNameTextField = app.textFields["TutorialButtonNameTextField"]
        tutorialButtonNameTextField.tap()
        tutorialButtonNameTextField.typeText("Button Name")
        
        let tutorialcommandtextfieldTextField = app.textFields["TutorialCommandTextField"]
        tutorialcommandtextfieldTextField.tap()
        tutorialcommandtextfieldTextField.typeText("command")
        
        app.buttons["TutorialAddButtonButton"].tap()
        
        let error = app.alerts["Error"]
        XCTAssertTrue(error.exists)
        XCTAssertEqual(error.staticTexts.element(boundBy: 1).label, "Looks like you did not configure a server. You might want to do that first.")
        
        error.buttons["OK"].tap()
        
        XCTAssertFalse(error.exists)
        
    }
    
    func testTutorialAddButton() {
        // First add a button by tapping in textfields, typing the info and tapping the "Add Button" button.
        // Then add a button with the keyboard only.

        app.buttons["TutorialNextButton1"].tap()
        app.buttons["TutorialNextButton2"].tap()
        
        let ServerNameTextField = app.textFields["TutorialServerNameTextField"]
        ServerNameTextField.tap()
        ServerNameTextField.typeText("NewServer")
        
        let HostAddressTextField = app.textFields["TutorialHostAddressTextField"]
        HostAddressTextField.tap()
        HostAddressTextField.typeText("http://NewServer.local")
        
        let PortNumberTextField = app.textFields["TutorialPortNumberTextField"]
        PortNumberTextField.tap()
        PortNumberTextField.typeText("1234")
        
        app.buttons["TutorialAddServerButton"].tap()
        
        app.buttons["TutorialNextButton4"].tap()
        
        let tutorialButtonNameTextField = app.textFields["TutorialButtonNameTextField"]
        tutorialButtonNameTextField.tap()
        tutorialButtonNameTextField.typeText("Button Name")
        
        let tutorialcommandtextfieldTextField = app.textFields["TutorialCommandTextField"]
        tutorialcommandtextfieldTextField.tap()
        tutorialcommandtextfieldTextField.typeText("command")
        
        app.buttons["TutorialAddButtonButton"].tap()
        
        let welldone = app.alerts["Well done!"]
        
        XCTAssertTrue(welldone.exists)
        
        welldone.buttons["OK"].tap()
        
        XCTAssertFalse(welldone.exists)
        
        // Now try to do it again with the keyboard only (hitting return key instead of tapping in the textfields and buttons)
        
        tutorialButtonNameTextField.tap()
        tutorialButtonNameTextField.typeText("Button Name\r")
        tutorialcommandtextfieldTextField.typeText("command\r")
  
        // Because you're adding the same command twice, there should now be an error message
        
        let error = app.alerts["Error"]
        XCTAssertTrue(error.exists)
        XCTAssertEqual(error.staticTexts.element(boundBy: 1).label, "Button was not added because that command already has a button.")
        
        error.buttons["OK"].tap()

        // Let's try again one more time with a different button name (it shoud still throw an error message)
        
        tutorialButtonNameTextField.tap()
        tutorialButtonNameTextField.clearText()
        tutorialButtonNameTextField.typeText("Other Button Name\r")
        tutorialcommandtextfieldTextField.typeText("\r")
        
        // Because it's the same command, there should still be an error message

        XCTAssertTrue(error.exists)
        XCTAssertEqual(error.staticTexts.element(boundBy: 1).label, "Button was not added because that command already has a button.")
        
        error.buttons["OK"].tap()
        
        XCTAssertFalse(error.exists)

        
    }
    
    func testTutorialAddButtonWithInvalidCommand() {
        // First add a button by tapping in textfields, typing the info and tapping the "Add Button" button.
        // Then add a button with the keyboard only.
        
        app.buttons["TutorialNextButton1"].tap()
        app.buttons["TutorialNextButton2"].tap()
        
        let ServerNameTextField = app.textFields["TutorialServerNameTextField"]
        ServerNameTextField.tap()
        ServerNameTextField.typeText("NewServer")
        
        let HostAddressTextField = app.textFields["TutorialHostAddressTextField"]
        HostAddressTextField.tap()
        HostAddressTextField.typeText("http://NewServer.local")
        
        let PortNumberTextField = app.textFields["TutorialPortNumberTextField"]
        PortNumberTextField.tap()
        PortNumberTextField.typeText("1234")
        
        app.buttons["TutorialAddServerButton"].tap()
        
        app.buttons["TutorialNextButton4"].tap()
        
        let tutorialButtonNameTextField = app.textFields["TutorialButtonNameTextField"]
        tutorialButtonNameTextField.tap()
        tutorialButtonNameTextField.typeText("Button Name\r")
        
        let tutorialcommandtextfieldTextField = app.textFields["TutorialCommandTextField"]
        tutorialcommandtextfieldTextField.typeText("a command with spaces\r")
        
        // There should be an error message, there cannot be spaces in the command.
        
        let error = app.alerts["Error"]
        XCTAssertTrue(error.exists)
        XCTAssertEqual(error.staticTexts.element(boundBy: 1).label, "That command is not valid.")
        
        error.buttons["OK"].tap()

        XCTAssertFalse(error.exists)
    }

    func testTutorialAddButtonWithEmptyCommand() {
        // First add a button by tapping in textfields, typing the info and tapping the "Add Button" button.
        // Then add a button with the keyboard only.
        
        app.buttons["TutorialNextButton1"].tap()
        app.buttons["TutorialNextButton2"].tap()
        
        let ServerNameTextField = app.textFields["TutorialServerNameTextField"]
        ServerNameTextField.tap()
        ServerNameTextField.typeText("NewServer")
        
        let HostAddressTextField = app.textFields["TutorialHostAddressTextField"]
        HostAddressTextField.tap()
        HostAddressTextField.typeText("http://NewServer.local")
        
        let PortNumberTextField = app.textFields["TutorialPortNumberTextField"]
        PortNumberTextField.tap()
        PortNumberTextField.typeText("1234")
        
        app.buttons["TutorialAddServerButton"].tap()
        
        app.buttons["TutorialNextButton4"].tap()
        
        let tutorialButtonNameTextField = app.textFields["TutorialButtonNameTextField"]
        tutorialButtonNameTextField.tap()
        tutorialButtonNameTextField.typeText("Button Name\r")
        
        let tutorialcommandtextfieldTextField = app.textFields["TutorialCommandTextField"]
        tutorialcommandtextfieldTextField.typeText("\r")
        
        // There should be an error message, the command cannot be empty.
        
        let error = app.alerts["Error"]
        XCTAssertTrue(error.exists)
        XCTAssertEqual(error.staticTexts.element(boundBy: 1).label, "The command cannot be empty.")
        
        error.buttons["OK"].tap()
        
        XCTAssertFalse(error.exists)
    }
    
}

