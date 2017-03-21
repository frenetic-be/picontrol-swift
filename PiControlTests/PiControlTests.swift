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

class PiSettingsTests: XCTestCase {
    
    let pin = PiGPIOPin(number: 5)
    let pin2 = PiGPIOPin(number: 35)

    let gpio = PiGPIO()

    let cmd = PiCommand(buttonName: "Time")
    let cmd2 = PiCommand(buttonName: "Blah")

    let userCmds = PiUserCommands()
    
    let server = PiServer(name: "local", hostName: "localhost", port: 3000)

    let originalSettings = PiSettings()
    var settings = PiSettings()

    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        gpio.pins.append(pin)
        userCmds.commands.append(cmd2)
        originalSettings.load()
        settings = originalSettings.copy() as! PiSettings
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        originalSettings.save()
    }
    

//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

    // MARK: Test PiSettings data model
    
    func testGPIOPinTypeToInt(){
        let ptype: PiPinType = .input
        XCTAssertEqual(ptype.toInt() , 0)
        let ptype2: PiPinType = .output
        XCTAssertEqual(ptype2.toInt() , 1)
    }
    
    func testGPIOPinTypeFromInt(){
        let ptype = PiPinType.init(fromNumber: 0)
        XCTAssertEqual(ptype, .input)
        let ptype2 = PiPinType.init(fromNumber: 1)
        XCTAssertEqual(ptype2, .output)
    }
    
    func testGPIOPinInit(){
        XCTAssertEqual(pin.number, 5)
        XCTAssertEqual(pin.name, "GPIO-5")
        XCTAssertEqual(pin2.number, 27)
        XCTAssertEqual(pin2.name, "GPIO-27")
    }

    func testGPIOInit(){
        
        XCTAssertFalse(gpio.isOn)
        XCTAssertEqual(gpio.pins[0].number, 5)
        XCTAssertEqual(gpio.pins[0].name, "GPIO-5")
    }

    func testCommandInit(){
        XCTAssertEqual(cmd.buttonName, "Time")
        XCTAssertEqual(cmd.command, "time")
    }
    
    func testUserCommands(){
        XCTAssertFalse(userCmds.isOn)
        XCTAssertEqual(userCmds.commands[0].buttonName, "Blah")
        XCTAssertEqual(userCmds.commands[0].command, "blah")
    }
    
    func testServer(){
        XCTAssertEqual(server.name, "local")
        XCTAssertEqual(server.hostName, "localhost")
        XCTAssertEqual(server.port, 3000)
        XCTAssertFalse(server.anyCommand)
        XCTAssertFalse(server.userCommands.isOn)
        XCTAssertEqual(server.userCommands.commands.count, 0)
        XCTAssertFalse(server.gpio.isOn)
        XCTAssertEqual(server.gpio.pins.count, 0)
    }
    
    // MARK: Object equality
    func testGPIOPinEqual() {
        let pin_1 = PiGPIOPin(number: 7)
        let pin_2 = PiGPIOPin(number: 7)
        XCTAssertTrue(pin_1 == pin_2)
        
        pin_1.number = 8
        XCTAssertTrue(pin_1 != pin_2)
        pin_1.number = 7
        XCTAssertTrue(pin_1 == pin_2)
        
        pin_1.name = "BLAH"
        XCTAssertTrue(pin_1 != pin_2)
        pin_1.name = "GPIO-7"
        XCTAssertTrue(pin_1 == pin_2)
        
        pin_1.polling = 3
        XCTAssertTrue(pin_1 != pin_2)
        pin_1.polling = 5
        XCTAssertTrue(pin_1 == pin_2)
        
        pin_1.type = .input
        XCTAssertTrue(pin_1 != pin_2)
        pin_1.type = .output
        XCTAssertTrue(pin_1 == pin_2)
    }
    
    func testGPIOEqual() {
        let pin_1 = PiGPIOPin(number: 7)
        let pin_2 = PiGPIOPin(number: 7)
        let gpio_1 = PiGPIO()
        let gpio_2 = PiGPIO()
        gpio_1.pins.append(pin_1)
        gpio_2.pins.append(pin_2)
        XCTAssertTrue(gpio_1 == gpio_2)
        
        gpio_1.isOn = true
        XCTAssertTrue(gpio_1 != gpio_2)
        gpio_1.isOn = false
        XCTAssertTrue(gpio_1 == gpio_2)
        
        gpio_1.pins.append(PiGPIOPin(number: 9))
        XCTAssertTrue(gpio_1 != gpio_2)
        gpio_1.pins.remove(at: 1)
        XCTAssertTrue(gpio_1 == gpio_2)
        
        gpio_1.pins[0].name = "***"
        XCTAssertTrue(gpio_1 != gpio_2)
        gpio_1.pins[0].name = "GPIO-7"
        XCTAssertTrue(gpio_1 == gpio_2)
    }
    
    func testCommandEqual() {
        let cmd_1 = PiCommand(buttonName: "Blah")
        let cmd_2 = PiCommand(buttonName: "Blah")
        XCTAssertTrue(cmd_1 == cmd_2)
        
        cmd_1.buttonName = "Bloh"
        XCTAssertTrue(cmd_1 != cmd_2)
        cmd_1.buttonName = "Blah"
        XCTAssertTrue(cmd_1 == cmd_2)
        
        cmd_1.command = "bloh"
        XCTAssertTrue(cmd_1 != cmd_2)
        cmd_1.command = "blah"
        XCTAssertTrue(cmd_1 == cmd_2)
        
        cmd_1.commandHasArguments = true
        XCTAssertTrue(cmd_1 != cmd_2)
        cmd_1.commandHasArguments = false
        XCTAssertTrue(cmd_1 == cmd_2)
    }
    
    func testUserCommandsEqual() {
        let cmd_1 = PiCommand(buttonName: "Blah")
        let cmd_2 = PiCommand(buttonName: "Blah")
        let usercmd_1 = PiUserCommands()
        let usercmd_2 = PiUserCommands()
        usercmd_1.commands.append(cmd_1)
        usercmd_2.commands.append(cmd_2)
        XCTAssertTrue(usercmd_1 == usercmd_2)
        
        usercmd_1.isOn = true
        XCTAssertTrue(usercmd_1 != usercmd_2)
        usercmd_1.isOn = false
        XCTAssertTrue(usercmd_1 == usercmd_2)
        
        usercmd_1.commands.append(cmd_1)
        XCTAssertTrue(usercmd_1 != usercmd_2)
        usercmd_1.commands.remove(at: 1)
        XCTAssertTrue(usercmd_1 == usercmd_2)
        
        usercmd_1.commands[0].buttonName = "Bloh"
        XCTAssertTrue(usercmd_1 != usercmd_2)
        usercmd_1.commands[0].buttonName = "Blah"
        XCTAssertTrue(usercmd_1 == usercmd_2)
    }
    
    func testServerEqual() {
        let server_1 = PiServer(name: "blah", hostName: "blih", port: 2999)
        let server_2 = PiServer(name: "blah", hostName: "blih", port: 2999)
        XCTAssertTrue(server_1 == server_2)

        server_1.name = "bloh"
        XCTAssertTrue(server_1 != server_2)
        server_1.name = "blah"
        XCTAssertTrue(server_1 == server_2)
        
        server_1.hostName = "bloh"
        XCTAssertTrue(server_1 != server_2)
        server_1.hostName = "blih"
        XCTAssertTrue(server_1 == server_2)
        
        server_1.port = 2998
        XCTAssertTrue(server_1 != server_2)
        server_1.port = 2999
        XCTAssertTrue(server_1 == server_2)
        
        server_1.anyCommand = true
        XCTAssertTrue(server_1 != server_2)
        server_1.anyCommand = false
        XCTAssertTrue(server_1 == server_2)
        
        server_1.responseOn = true
        XCTAssertTrue(server_1 != server_2)
        server_1.responseOn = false
        XCTAssertTrue(server_1 == server_2)
        
        server_1.gpio.isOn = true
        XCTAssertTrue(server_1 != server_2)
        server_1.gpio.isOn = false
        XCTAssertTrue(server_1 == server_2)
        
        server_1.userCommands.isOn = true
        XCTAssertTrue(server_1 != server_2)
        server_1.userCommands.isOn = false
        XCTAssertTrue(server_1 == server_2)
    }
    
    func testSettingsEqual() {
        let server_1 = PiServer(name: "Blah", hostName: "Blih", port: 2999)
        let server_2 = PiServer(name: "Blah", hostName: "Blih", port: 2999)
        let settings_1 = PiSettings()
        settings_1.servers.append(server_1)
        let settings_2 = PiSettings()
        settings_2.servers.append(server_2)

        XCTAssertTrue(settings_1 == settings_2)
        
        settings_1.servers.append(server_1)
        XCTAssertTrue(settings_1 != settings_2)
        settings_1.servers.remove(at: 1)
        XCTAssertTrue(settings_1 == settings_2)
        
        // Currently not testint if selectedServer is the same
    }
    
    // MARK: NSCopying
    func testPiGPIOPinCopy() {
        let pin_1 = PiGPIOPin(number: 7)
        let pin_2 = pin_1.copy() as! PiGPIOPin
        XCTAssertTrue(pin_1 == pin_2)
        
        pin_1.number = 8
        XCTAssertTrue(pin_1 != pin_2)
        pin_1.number = 7
        XCTAssertTrue(pin_1 == pin_2)
        
        pin_1.name = "BLAH"
        XCTAssertTrue(pin_1 != pin_2)
        pin_1.name = "GPIO-7"
        XCTAssertTrue(pin_1 == pin_2)
        
        pin_1.polling = 3
        XCTAssertTrue(pin_1 != pin_2)
        pin_1.polling = 5
        XCTAssertTrue(pin_1 == pin_2)
        
        pin_1.type = .input
        XCTAssertTrue(pin_1 != pin_2)
        pin_1.type = .output
        XCTAssertTrue(pin_1 == pin_2)
    }
    
    func testPiGPIOCopy() {
        let pin_1 = PiGPIOPin(number: 7)
        let gpio_1 = PiGPIO()
        gpio_1.pins.append(pin_1)
        let gpio_2 = gpio_1.copy() as! PiGPIO
        XCTAssertTrue(gpio_1 == gpio_2)
        
        gpio_1.isOn = true
        XCTAssertTrue(gpio_1 != gpio_2)
        gpio_1.isOn = false
        XCTAssertTrue(gpio_1 == gpio_2)
        
        gpio_1.pins.append(PiGPIOPin(number: 9))
        XCTAssertTrue(gpio_1 != gpio_2)
        gpio_1.pins.remove(at: 1)
        XCTAssertTrue(gpio_1 == gpio_2)
        
        gpio_1.pins[0].name = "***"
        XCTAssertTrue(gpio_1 != gpio_2)
        gpio_1.pins[0].name = "GPIO-7"
        XCTAssertTrue(gpio_1 == gpio_2)
    }
    
    func testCommandCopy() {
        let cmd_1 = PiCommand(buttonName: "Blah")
        let cmd_2 = cmd_1.copy() as! PiCommand
        XCTAssertTrue(cmd_1 == cmd_2)
        
        cmd_1.buttonName = "Bloh"
        XCTAssertTrue(cmd_1 != cmd_2)
        cmd_1.buttonName = "Blah"
        XCTAssertTrue(cmd_1 == cmd_2)
        
        cmd_1.command = "bloh"
        XCTAssertTrue(cmd_1 != cmd_2)
        cmd_1.command = "blah"
        XCTAssertTrue(cmd_1 == cmd_2)
        
        cmd_1.commandHasArguments = true
        XCTAssertTrue(cmd_1 != cmd_2)
        cmd_1.commandHasArguments = false
        XCTAssertTrue(cmd_1 == cmd_2)
    }
 
    func testUserCommandsCopy() {
        let cmd_1 = PiCommand(buttonName: "Blah")
        let usercmd_1 = PiUserCommands()
        usercmd_1.commands.append(cmd_1)
        let usercmd_2 = usercmd_1.copy() as! PiUserCommands

        XCTAssertTrue(usercmd_1 == usercmd_2)
        
        usercmd_1.isOn = true
        XCTAssertTrue(usercmd_1 != usercmd_2)
        usercmd_1.isOn = false
        XCTAssertTrue(usercmd_1 == usercmd_2)
        
        usercmd_1.commands.append(cmd_1)
        XCTAssertTrue(usercmd_1 != usercmd_2)
        usercmd_1.commands.remove(at: 1)
        XCTAssertTrue(usercmd_1 == usercmd_2)
        
        usercmd_1.commands[0].buttonName = "Bloh"
        XCTAssertTrue(usercmd_1 != usercmd_2)
        usercmd_1.commands[0].buttonName = "Blah"
        XCTAssertTrue(usercmd_1 == usercmd_2)
    }
    
    func testServerCopy() {
        let server_1 = PiServer(name: "blah", hostName: "blih", port: 2999)
        let server_2 = server_1.copy() as! PiServer
        XCTAssertTrue(server_1 == server_2)
        
        server_1.name = "bloh"
        XCTAssertTrue(server_1 != server_2)
        server_1.name = "blah"
        XCTAssertTrue(server_1 == server_2)
        
        server_1.hostName = "bloh"
        XCTAssertTrue(server_1 != server_2)
        server_1.hostName = "blih"
        XCTAssertTrue(server_1 == server_2)
        
        server_1.port = 2998
        XCTAssertTrue(server_1 != server_2)
        server_1.port = 2999
        XCTAssertTrue(server_1 == server_2)
        
        server_1.anyCommand = true
        XCTAssertTrue(server_1 != server_2)
        server_1.anyCommand = false
        XCTAssertTrue(server_1 == server_2)
        
        server_1.responseOn = true
        XCTAssertTrue(server_1 != server_2)
        server_1.responseOn = false
        XCTAssertTrue(server_1 == server_2)
        
        server_1.gpio.isOn = true
        XCTAssertTrue(server_1 != server_2)
        server_1.gpio.isOn = false
        XCTAssertTrue(server_1 == server_2)
        
        server_1.gpio.pins.append(PiGPIOPin(number: 21))
        XCTAssertTrue(server_1 != server_2)
        server_1.gpio.pins.remove(at: 0)
        XCTAssertTrue(server_1 == server_2)
        
        server_1.userCommands.isOn = true
        XCTAssertTrue(server_1 != server_2)
        server_1.userCommands.isOn = false
        XCTAssertTrue(server_1 == server_2)
        
        server_1.userCommands.commands.append(PiCommand(buttonName: "BLAHBLAH"))
        XCTAssertTrue(server_1 != server_2)
        server_1.userCommands.commands.remove(at: 0)
        XCTAssertTrue(server_1 == server_2)
    }
    
    func testSettingsCopy() {
        let server_1 = PiServer(name: "Blah", hostName: "Blih", port: 2999)
        let server_2 = PiServer(name: "Bloh", hostName: "Bleh", port: 3000)
        let settings_1 = PiSettings()
        settings_1.servers.append(server_1)
        settings_1.servers.append(server_2)
        let settings_2 = settings_1.copy() as! PiSettings
        
        XCTAssertTrue(settings_1 == settings_2)
        
        settings_1.servers.append(server_1)
        XCTAssertTrue(settings_1 != settings_2)
        settings_1.servers.remove(at: 2)
        XCTAssertTrue(settings_1 == settings_2)
        
        server_1.name = "GRGRRGR"
        XCTAssertTrue(settings_1 != settings_2)
        server_1.name = "Blah"
        XCTAssertTrue(settings_1 == settings_2)
        XCTAssertEqual(settings_1.selectedServer?.name, settings_2.selectedServer?.name)
    }

    

    func testSettingsSaveAndLoad(){
        XCTAssertTrue(settings == originalSettings)
        
        let server_1 = PiServer(name: "Blah", hostName: "Blih", port: 2999)
        settings.servers.append(server_1)
        settings.selectedServer = settings.servers.first
        settings.save()
        
        let settings_2 = PiSettings()
        settings_2.load()
        
        XCTAssertTrue(settings == settings_2)
        XCTAssertTrue(settings_2 != originalSettings)
        
        settings.servers.removeLast()
        settings.selectedServer = nil
        settings.save()
        
        let settings_3 = PiSettings()
        settings_3.load()
        
        XCTAssertTrue(settings == settings_3)
        XCTAssertTrue(settings_3 != settings)
        XCTAssertTrue(settings_3 == originalSettings)

        
    }
}
