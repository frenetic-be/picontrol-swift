//
//  PiControlTests.swift
//  PiControlTests
//
//  Created by Julien Spronck on 11/02/2017.
//  Copyright © 2017 Julien Spronck. All rights reserved.
//

import PiControl

import XCTest
@testable import PiControl

class PiControlTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

    // MARK: Test PiSettings data model
    func testGPIOPinInit(){
        let pin = PiGPIOPin(number: 5)
        XCTAssertEqual(pin.number, 5)
        XCTAssertEqual(pin.name, "GPIO-5")
        let pin2 = PiGPIOPin(number: 35)
        XCTAssertEqual(pin2.number, 27)
        XCTAssertEqual(pin2.name, "GPIO-27")
    }

    func testGPIOInit(){
        let gpio = PiGPIO()
        XCTAssertFalse(gpio.isOn)
        let pin = PiGPIOPin(number: 5)
        gpio.pins.append(pin)
        XCTAssertEqual(gpio.pins[0].number, 5)
        XCTAssertEqual(gpio.pins[0].name, "GPIO-5")
    }

    func testCommandInit(){
        let cmd = PiCommand(buttonName: "Time")
        XCTAssertEqual(cmd.buttonName, "Time")
        XCTAssertEqual(cmd.command, "time")
    }
    
    func testUserCommands(){
        let userCmds = PiUserCommands()
        XCTAssertFalse(userCmds.isOn)
        let cmd = PiCommand(buttonName: "Blah")
        userCmds.commands.append(cmd)
        XCTAssertEqual(userCmds.commands[0].buttonName, "Blah")
        XCTAssertEqual(userCmds.commands[0].command, "blah")
    }
    
    func testServer(){
        let server = PiServer(name: "local", hostName: "localhost", port: 3000)
        XCTAssertEqual(server.name, "local")
        XCTAssertEqual(server.hostName, "localhost")
        XCTAssertEqual(server.port, 3000)
        XCTAssertFalse(server.anyCommand)
        XCTAssertFalse(server.userCommands.isOn)
        XCTAssertEqual(server.userCommands.commands.count, 0)
        XCTAssertFalse(server.gpio.isOn)
        XCTAssertEqual(server.gpio.pins.count, 0)
    }
}
