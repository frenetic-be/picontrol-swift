//
//  PiControlUITests.swift
//  PiControl
//
//  Created by Julien Spronck on 22/03/2017.
//  Copyright © 2017 Julien Spronck. All rights reserved.
//

import XCTest


class PiControlUITests: XCTestCase {
    
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
    
    func testSwitchTabs() {
        // Switch between Dashboard and Settings tabs
        
        // Skip tutorial
        app.buttons["TutorialSkipButton1"].tap()
        
        // Go to Settings
        let tab = app.tabBars.element(boundBy: 0)
        tab.buttons["Settings"].tap()
        
        
        XCTAssertEqual(tab.identifier, "Settings")
        
        // Go back to Dashboard
        tab.buttons["Dashboard"].tap()
        
        XCTAssertEqual(tab.identifier, "Dashboard")
        
    }
    
    func testAddServer() {
        // Add Server by clicking the + button in ServerList Settings page
        
        
        // Skip tutorial
        app.buttons["TutorialSkipButton1"].tap()
        
        // Go to Settings
        let tab = app.tabBars.element(boundBy: 0)
        tab.buttons["Settings"].tap()
        
        
        XCTAssertEqual(tab.identifier, "Settings")
        
        // Tap Add Server
        let navbar = app.navigationBars.element(boundBy: 0)
        _ = navbar.buttons["Add"].tap()
        
        XCTAssertEqual(navbar.identifier, "ServerConfigNavBar")
        
        let tables = app.tables

        let save = navbar.buttons["Save"]
        
        // Check that Save button is disabled at first
        XCTAssertFalse(save.isEnabled)
        
        let configServerNameTextField = tables.textFields["ConfigServerNameTextField"]
        configServerNameTextField.tap()
        configServerNameTextField.typeText("NewServer")
        tables.textFields["ConfigHostAddressTextField"].tap()
        
        // Check that Save button is enabled after we entered a server name
        XCTAssertTrue(save.isEnabled)
        
        save.tap()
        
        // We should now be back on the Server List page
        XCTAssertEqual(navbar.identifier, "ServerListNavBar")
        
        let newServer = tables.staticTexts["ServerListLabel"]
        XCTAssertTrue(newServer.exists)
        XCTAssertEqual(newServer.label, "\u{2713}  NewServer")

    }

    func testCancelAddingServer() {
        // Add Server by clicking the + button in ServerList Settings page and then tap "Cancel"
        
        
        // Skip tutorial
        app.buttons["TutorialSkipButton1"].tap()
        
        // Go to Settings
        let tab = app.tabBars.element(boundBy: 0)
        tab.buttons["Settings"].tap()
        
        
        XCTAssertEqual(tab.identifier, "Settings")
        
        // Tap Add Server
        let navbar = app.navigationBars.element(boundBy: 0)
        _ = navbar.buttons["Add"].tap()
        
        let tables = app.tables
        
        let cancel = navbar.buttons["Cancel"]
        
        let configServerNameTextField = tables.textFields["ConfigServerNameTextField"]
        configServerNameTextField.tap()
        configServerNameTextField.typeText("NewServer")
        tables.textFields["ConfigHostAddressTextField"].tap()
        
        cancel.tap()
        
        // We should now be back on the Server List page
        XCTAssertEqual(navbar.identifier, "ServerListNavBar")
        
        let newServer = tables.staticTexts["ServerListLabel"]
        XCTAssertFalse(newServer.exists)
        
    }
    
    func testDeleteServers() {
        // Add two servers and then delete both of them: the first one using the Edit button, the second one by swiping left.
        
        
        // Skip tutorial
        app.buttons["TutorialSkipButton1"].tap()
        
        // Go to Settings
        let tab = app.tabBars.element(boundBy: 0)
        tab.buttons["Settings"].tap()
        
        
        XCTAssertEqual(tab.identifier, "Settings")
        
        // Tap Add Server
        let navbar = app.navigationBars.element(boundBy: 0)
        let add = navbar.buttons["Add"]
            
        add.tap()
        
        let tables = app.tables
        
        let save = navbar.buttons["Save"]
        
        let configServerNameTextField = tables.textFields["ConfigServerNameTextField"]
        configServerNameTextField.tap()
        configServerNameTextField.typeText("NewServer")
        tables.textFields["ConfigHostAddressTextField"].tap()
        
        save.tap()
        
        // We should now be back on the Server List page
        XCTAssertEqual(navbar.identifier, "ServerListNavBar")
        
        // Add a second server
        add.tap()
 
        configServerNameTextField.tap()
        configServerNameTextField.typeText("NewServer2")
        tables.textFields["ConfigHostAddressTextField"].tap()
        
        save.tap()
        
        let firstCell = tables.cells.element(boundBy: 0)
        let secondCell = tables.cells.element(boundBy: 1)
        
        XCTAssertEqual(firstCell.staticTexts.element.label, "\u{2713}  NewServer")
        XCTAssertEqual(secondCell.staticTexts.element.label, "\u{2001}  NewServer2")
        
        // Delete one row by pressing the "Edit" button
        navbar.buttons["Edit"].tap()
        
        firstCell.buttons.element(matching: NSPredicate(format: "label BEGINSWITH 'Delete'")).tap()
        firstCell.buttons["Delete"].tap()
        
        XCTAssertEqual(firstCell.staticTexts.element.label, "\u{2713}  NewServer2")
        XCTAssertFalse(secondCell.exists)
        
        // Delete the last row by swiping left
        navbar.buttons["Done"].tap()
        
        firstCell.staticTexts.element.swipeLeft()
        firstCell.buttons["Delete"].tap()
        
        XCTAssertFalse(firstCell.exists)
        
    }
    
    func testReorderServers() {
        
        // Add two servers and then delete both of them: the first one using the Edit button, the second one by swiping left.
        
        
        // Skip tutorial
        app.buttons["TutorialSkipButton1"].tap()
        
        // Go to Settings
        let tab = app.tabBars.element(boundBy: 0)
        tab.buttons["Settings"].tap()
        
        
        XCTAssertEqual(tab.identifier, "Settings")
        
        // Tap Add Server
        let navbar = app.navigationBars.element(boundBy: 0)
        let add = navbar.buttons["Add"]
        
        add.tap()
        
        let tables = app.tables
        
        let save = navbar.buttons["Save"]
        
        let configServerNameTextField = tables.textFields["ConfigServerNameTextField"]
        configServerNameTextField.tap()
        configServerNameTextField.typeText("NewServer")
        tables.textFields["ConfigHostAddressTextField"].tap()
        
        save.tap()
        
        // We should now be back on the Server List page
        XCTAssertEqual(navbar.identifier, "ServerListNavBar")
        
        // Add a second server
        add.tap()
        
        configServerNameTextField.tap()
        configServerNameTextField.typeText("NewServer2")
        tables.textFields["ConfigHostAddressTextField"].tap()
        
        save.tap()
        
        let firstCell = tables.cells.element(boundBy: 0)
        let secondCell = tables.cells.element(boundBy: 1)
        
        XCTAssertEqual(firstCell.staticTexts.element.label, "\u{2713}  NewServer")
        XCTAssertEqual(secondCell.staticTexts.element.label, "\u{2001}  NewServer2")
        
        // Reorder the top
        navbar.buttons["Edit"].tap()
        
        let topButton = firstCell.buttons.element(matching: NSPredicate(format: "label BEGINSWITH 'Reorder'"))
        let bottomButton = secondCell.buttons.element(matching: NSPredicate(format: "label BEGINSWITH 'Reorder'"))
        bottomButton.press(forDuration: 0.5, thenDragTo: topButton)
        
        XCTAssertEqual(firstCell.staticTexts.element.label, "\u{2001}  NewServer2")
        XCTAssertEqual(secondCell.staticTexts.element.label, "\u{2713}  NewServer")

        navbar.buttons["Done"].tap()
        
    }
    
    func testAddSameServerTwice() {
        // Add two servers and then delete both of them: the first one using the Edit button, the second one by swiping left.
        
        
        // Skip tutorial
        app.buttons["TutorialSkipButton1"].tap()
        
        // Go to Settings
        let tab = app.tabBars.element(boundBy: 0)
        tab.buttons["Settings"].tap()
        
        
        XCTAssertEqual(tab.identifier, "Settings")
        
        // Tap Add Server
        let navbar = app.navigationBars.element(boundBy: 0)
        let add = navbar.buttons["Add"]
        
        add.tap()
        
        let tables = app.tables
        
        let save = navbar.buttons["Save"]
        
        // Enter new server name and hit return to move on to the host address text field
        let configServerNameTextField = tables.textFields["ConfigServerNameTextField"]
        configServerNameTextField.tap()
        configServerNameTextField.typeText("NewServer\r")
        let configHostAddressTextField = tables.textFields["ConfigHostAddressTextField"]
        configHostAddressTextField.clearText()
        configHostAddressTextField.typeText("http://NewServer.local\r")
        let configPortNumberTextField = tables.textFields["ConfigPortNumberTextField"]
        configPortNumberTextField.clearText()
        configPortNumberTextField.typeText("1234\r")
        
        save.tap()
        
        // We should now be back on the Server List page
        XCTAssertEqual(navbar.identifier, "ServerListNavBar")
        
        // Add a second server
        add.tap()
        
        configServerNameTextField.tap()
        configServerNameTextField.typeText("NewServer\r")
        
        let alert = app.alerts["Error"]
        XCTAssertTrue(alert.exists)
        XCTAssertEqual(alert.staticTexts.element(boundBy: 1).label, "Server name already exists, please choose another name.")
        alert.buttons["OK"].tap()
        
        // Change the server name to enable save button
        configServerNameTextField.tap()
        configServerNameTextField.typeText("2\r")
        configHostAddressTextField.clearText()
        configHostAddressTextField.typeText("http://NewServer.local\r")
        configPortNumberTextField.clearText()
        configPortNumberTextField.typeText("1234\r")
        
        // Change back to existing server name and tap save directly
        configServerNameTextField.tap()
        configServerNameTextField.clearText()
        configServerNameTextField.typeText("NewServer")

        // Check that the save button is disabled again
        XCTAssertFalse(save.isEnabled)
        
        // Nothing should happen if save is tapped because it should be disabled
        save.tap()
        
        configPortNumberTextField.tap()
        configServerNameTextField.tap()
        configServerNameTextField.clearText()
        configServerNameTextField.typeText("NewServer2")
        
        XCTAssertTrue(save.isEnabled)
        save.tap()
        
        let firstCell = tables.cells.element(boundBy: 0)
        let secondCell = tables.cells.element(boundBy: 1)
        
        
        XCTAssertEqual(firstCell.staticTexts.element.label, "\u{2713}  NewServer")
        XCTAssertEqual(secondCell.staticTexts.element.label, "\u{2001}  NewServer2")
    }
    
    func testEnabledSaveButton() {
        // save button should be disabled when server name or host address is empty
        
        // Skip tutorial
        app.buttons["TutorialSkipButton1"].tap()
        
        // Go to Settings
        let tab = app.tabBars.element(boundBy: 0)
        tab.buttons["Settings"].tap()
        
        
        XCTAssertEqual(tab.identifier, "Settings")
        
        // Tap Add Server
        let navbar = app.navigationBars.element(boundBy: 0)
        let add = navbar.buttons["Add"]
        
        add.tap()
        
        let tables = app.tables
        
        let save = navbar.buttons["Save"]
        
        // Check that the save button is disabled (server name is empty)
        XCTAssertFalse(save.isEnabled)
        
        // Enter new server name and hit return to move on to the host address text field
        let configServerNameTextField = tables.textFields["ConfigServerNameTextField"]
        configServerNameTextField.tap()
        configServerNameTextField.typeText("a")

        // Check that the save button is enabled (server name is not empty)
        XCTAssertTrue(save.isEnabled)
        
        configServerNameTextField.typeText("\r")
        let configHostAddressTextField = tables.textFields["ConfigHostAddressTextField"]
        configHostAddressTextField.clearText()
        
        // Check that the save button is disabled (host address is empty)
        XCTAssertFalse(save.isEnabled)
        
        configHostAddressTextField.typeText("b")

        // Check that the save button is enabled (host address is not empty)
        XCTAssertTrue(save.isEnabled)
        
        configServerNameTextField.tap()
        configServerNameTextField.clearText()
        
        // Check that the save button is disabled (server name is empty)
        XCTAssertFalse(save.isEnabled)
        
        configServerNameTextField.typeText("a")
        
        // Check that the save button is enabled (server name is not empty)
        XCTAssertTrue(save.isEnabled)
        
        let configPortNumberTextField = tables.textFields["ConfigPortNumberTextField"]
        configPortNumberTextField.tap()
        configPortNumberTextField.clearText()
        
        // Check that the save button is disabled (port number is empty)
        XCTAssertFalse(save.isEnabled)
        
        for j in 1...5 {
            configPortNumberTextField.typeText("1")
            if j == 4 {
                // Check that the save button is enabled (4-digit port number)
                XCTAssertTrue(save.isEnabled)
            } else {
                // Check that the save button is disabled (invalid port number)
                XCTAssertFalse(save.isEnabled)
            }
        }

    }
    
    func testInvalidPortNumber() {
        // The port number must be a 4-digit string
        
        // Skip tutorial
        app.buttons["TutorialSkipButton1"].tap()
        
        // Go to Settings
        let tab = app.tabBars.element(boundBy: 0)
        tab.buttons["Settings"].tap()
        
        
        XCTAssertEqual(tab.identifier, "Settings")
        
        // Tap Add Server
        let navbar = app.navigationBars.element(boundBy: 0)
        let add = navbar.buttons["Add"]
        
        add.tap()
        
        let tables = app.tables
        
        let configPortNumberTextField = tables.textFields["ConfigPortNumberTextField"]
        configPortNumberTextField.tap()
        configPortNumberTextField.clearText()
        
        // Test empty port number
        configPortNumberTextField.typeText("\r")
       
        let alert = app.alerts["Error"]
        XCTAssertTrue(alert.exists)
        XCTAssertEqual(alert.staticTexts.element(boundBy: 1).label, "The port number must be a 4-digit integer.")
        alert.buttons["OK"].tap()
        XCTAssertFalse(alert.exists)
        
        // Invalid character
        configPortNumberTextField.tap()
        configPortNumberTextField.typeText("a")
        
        XCTAssertTrue(alert.exists)
        XCTAssertEqual(alert.staticTexts.element(boundBy: 1).label, "The port number must be a 4-digit integer.")
        alert.buttons["OK"].tap()
        XCTAssertFalse(alert.exists)
        
        // Wrong number of digits
        configPortNumberTextField.clearText()
        
        for j in 1...5 {
            configPortNumberTextField.typeText("1\r")
            
            if j == 4 {
                XCTAssertFalse(alert.exists)
            } else {
                XCTAssertTrue(alert.exists)
                XCTAssertEqual(alert.staticTexts.element(boundBy: 1).label, "The port number must be a 4-digit integer.")
                alert.buttons["OK"].tap()
                XCTAssertFalse(alert.exists)
            }
            
            configPortNumberTextField.tap()
        }
        
    }
    
    func testKeyboardVisibleWhenTappingServerName() {
        // When tapping on server name text field, the keyboard should be visible. When hitting return on port number text field, the keyboard should be dismissed.
        
        // Skip tutorial
        app.buttons["TutorialSkipButton1"].tap()
        
        // Go to Settings
        let tab = app.tabBars.element(boundBy: 0)
        tab.buttons["Settings"].tap()
        
        
        XCTAssertEqual(tab.identifier, "Settings")
        
        // Tap Add Server
        let navbar = app.navigationBars.element(boundBy: 0)
        let add = navbar.buttons["Add"]
        
        add.tap()
        
        let tables = app.tables
        
        // Check that the keyboard is not visible
        XCTAssertTrue(app.keyboards.count == 0)
        
        // Enter new server name and hit return to move on to the host address text field
        let configServerNameTextField = tables.textFields["ConfigServerNameTextField"]
        configServerNameTextField.tap()
        
        // Check that the keyboard is visible
        XCTAssertTrue(app.keyboards.count > 0)
        
        // Move to host address text field
        configServerNameTextField.typeText("\r")
        
        let configHostAddressTextField = tables.textFields["ConfigHostAddressTextField"]
        
        // Check that the keyboard is still visible
        XCTAssertTrue(app.keyboards.count > 0)
        
        // move to port number text field
        configHostAddressTextField.typeText("\r")
 
        let configPortNumberTextField = tables.textFields["ConfigPortNumberTextField"]
        
        // Check that the keyboard is still visible
        XCTAssertTrue(app.keyboards.count > 0)
        
        // move away from port number text field
        configPortNumberTextField.typeText("\r")

        // Check that the keyboard is no longer visible
        XCTAssertTrue(app.keyboards.count == 0)
        
    }
    
    func testServerConfigSwitches() {
        // Initially both switches should be off, let's try to turn them on
        

        // Skip tutorial
        app.buttons["TutorialSkipButton1"].tap()
        
        // Go to Settings
        let tab = app.tabBars.element(boundBy: 0)
        tab.buttons["Settings"].tap()
        
        
        XCTAssertEqual(tab.identifier, "Settings")
        
        // Tap Add Server
        let navbar = app.navigationBars.element(boundBy: 0)
        let add = navbar.buttons["Add"]
        
        add.tap()
        
        // Check that all switches are off and that they all turn on when tapped
        for j in 0...app.switches.count-1 {
            let s = app.switches.element(boundBy: j)
            XCTAssertEqual(s.value as! String, "0")
            s.tap()
            XCTAssertEqual(s.value as! String, "1")
        }
        
    }
    
    func testGoToCommandsAndGPIOTableViews() {
        // Initially both switches should be off, let's try to turn them on
        
        
        // Skip tutorial
        app.buttons["TutorialSkipButton1"].tap()
        
        // Go to Settings
        let tab = app.tabBars.element(boundBy: 0)
        tab.buttons["Settings"].tap()
        
        
        XCTAssertEqual(tab.identifier, "Settings")
        
        // Tap Add Server
        let navbar = app.navigationBars.element(boundBy: 0)
        let add = navbar.buttons["Add"]
        
        add.tap()
        
        
        let tables = app.tables
        
        XCTAssertEqual(navbar.identifier, "ServerConfigNavBar")
        
        // Tap on User-defined commands
        tables.staticTexts["ConfigUserCommandsLabel"].tap()
        
        XCTAssertEqual(navbar.identifier, "UserCommandsNavBar")
        
        navbar.buttons["New Pi"].tap()
        
        XCTAssertEqual(navbar.identifier, "ServerConfigNavBar")
        
        tables.staticTexts["ConfigGPIOLabel"].tap()
        
        XCTAssertEqual(navbar.identifier, "GPIONavBar")
        
        navbar.buttons["New Pi"].tap()
        
        XCTAssertEqual(navbar.identifier, "ServerConfigNavBar")
        
        
    }
    
    func testSelectServers() {
        // Add two servers and then select one of them
        
        
        // Skip tutorial
        app.buttons["TutorialSkipButton1"].tap()
        
        // Go to Settings
        let tab = app.tabBars.element(boundBy: 0)
        tab.buttons["Settings"].tap()
        
        
        XCTAssertEqual(tab.identifier, "Settings")
        
        // Tap Add Server
        let navbar = app.navigationBars.element(boundBy: 0)
        let add = navbar.buttons["Add"]
        
        add.tap()
        
        let tables = app.tables
        
        let save = navbar.buttons["Save"]
        
        let configServerNameTextField = tables.textFields["ConfigServerNameTextField"]
        configServerNameTextField.tap()
        configServerNameTextField.typeText("NewServer")
        tables.textFields["ConfigHostAddressTextField"].tap()
        
        save.tap()
        
        // We should now be back on the Server List page
        XCTAssertEqual(navbar.identifier, "ServerListNavBar")
        
        // Add a second server
        add.tap()
        
        configServerNameTextField.tap()
        configServerNameTextField.typeText("NewServer2")
        tables.textFields["ConfigHostAddressTextField"].tap()
        
        save.tap()
        
        let firstCell = tables.cells.element(boundBy: 0)
        let secondCell = tables.cells.element(boundBy: 1)
        
        XCTAssertEqual(firstCell.staticTexts.element.label, "\u{2713}  NewServer")
        XCTAssertEqual(secondCell.staticTexts.element.label, "\u{2001}  NewServer2")
        
        // Select the bottom server
        secondCell.staticTexts.element.tap()
        
        XCTAssertEqual(firstCell.staticTexts.element.label, "\u{2001}  NewServer")
        XCTAssertEqual(secondCell.staticTexts.element.label, "\u{2713}  NewServer2")
    }
    
    func testShowServer() {
        // Add two servers and then display one and then the other
        
        
        // Skip tutorial
        app.buttons["TutorialSkipButton1"].tap()
        
        // Go to Settings
        let tab = app.tabBars.element(boundBy: 0)
        tab.buttons["Settings"].tap()
        
        
        XCTAssertEqual(tab.identifier, "Settings")
        
        // Tap Add Server
        let navbar = app.navigationBars.element(boundBy: 0)
        let add = navbar.buttons["Add"]
        
        add.tap()
        
        let tables = app.tables
        
        let save = navbar.buttons["Save"]
        
        let configServerNameTextField = tables.textFields["ConfigServerNameTextField"]
        configServerNameTextField.tap()
        configServerNameTextField.typeText("NewServer\r")
        let configHostAddressTextField = tables.textFields["ConfigHostAddressTextField"]
        let configPortNumberTextField = tables.textFields["ConfigPortNumberTextField"]
        configHostAddressTextField.clearText()
        configHostAddressTextField.typeText("http://NewServer.local\r")
        configPortNumberTextField.clearText()
        configPortNumberTextField.typeText("1234\r")
        
        save.tap()
        
        // We should now be back on the Server List page
        XCTAssertEqual(navbar.identifier, "ServerListNavBar")
        
        // Add a second server
        add.tap()
        
        configServerNameTextField.tap()
        configServerNameTextField.typeText("NewServer2\r")
        configHostAddressTextField.clearText()
        configHostAddressTextField.typeText("http://NewServer2.local\r")
        configPortNumberTextField.clearText()
        configPortNumberTextField.typeText("5678\r")
        
        save.tap()
        
        // We should now be back on the Server List page
        XCTAssertEqual(navbar.identifier, "ServerListNavBar")
        
        let firstCell = tables.cells.element(boundBy: 0)
        let secondCell = tables.cells.element(boundBy: 1)
        
        XCTAssertEqual(firstCell.staticTexts.element.label, "\u{2713}  NewServer")
        XCTAssertEqual(secondCell.staticTexts.element.label, "\u{2001}  NewServer2")
        
        // Display the top server
        let firstMoreInfoButton = firstCell.buttons.element(matching: NSPredicate(format: "label BEGINSWITH 'More Info'"))
        firstMoreInfoButton.tap()
        
        // We should now be on the Server Config page
        XCTAssertEqual(navbar.identifier, "ServerConfigNavBar")
        
        // Check text field values
        XCTAssertEqual(configServerNameTextField.value as! String, "NewServer")
        XCTAssertEqual(configHostAddressTextField.value as! String, "http://NewServer.local")
        XCTAssertEqual(configPortNumberTextField.value as! String, "1234")
        
        let cancelButton = navbar.buttons["Cancel"]
        cancelButton.tap()

        // We should now be back on the Server List page
        XCTAssertEqual(navbar.identifier, "ServerListNavBar")
        
        // Display the bottom server
        let secondMoreInfoButton = secondCell.buttons.element(matching: NSPredicate(format: "label BEGINSWITH 'More Info'"))
        secondMoreInfoButton.tap()
        
        // We should now be on the Server Config page
        XCTAssertEqual(navbar.identifier, "ServerConfigNavBar")
        
        // Check text field values
        XCTAssertEqual(configServerNameTextField.value as! String, "NewServer2")
        XCTAssertEqual(configHostAddressTextField.value as! String, "http://NewServer2.local")
        XCTAssertEqual(configPortNumberTextField.value as! String, "5678")
        
        cancelButton.tap()
        
        // We should now be back on the Server List page
        XCTAssertEqual(navbar.identifier, "ServerListNavBar")
        
    }
    
    // Server config:

    
    
    // On every page:
    // - Test tap anywhere to dismiss keyboard
    // - Test row selection
    // - Test return keys on text fields
    
    
    
}
