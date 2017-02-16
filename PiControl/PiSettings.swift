//
//  PiSettings.swift
//  PiControl
//
//  Created by Julien Spronck on 11/02/2017.
//  Copyright © 2017 Julien Spronck. All rights reserved.
//

import UIKit
import os.log


/**
 Class representing the user settings
 */
class PiSettings: NSObject, NSCoding {
    
    /// List of servers
    var servers = [PiServer]()
    
    /// Selected server
    var selectedServer: PiServer?
    
    // MARK: Methods
    
    func string() -> String {
        var str = "Settings:\n    Servers:\n"
        for server in servers {
            server.string().enumerateLines { (line, stop) in
                str.append("        \(line)\n")
            }
        }
        str.append("    Selected server: \(selectedServer?.name ?? "")\n")
        return str
    }
    
    func load() {
        if let loadedData = UserDefaults().data(forKey: "PiSettings") {
            if let loadedSettings = NSKeyedUnarchiver.unarchiveObject(with: loadedData) as? PiSettings {
                for server in loadedSettings.servers {
                    servers.append(server)
                }
                if servers.count == 1 {
                    selectedServer = servers[0]
                } else {
                    selectedServer = loadedSettings.selectedServer
                }
                print(string())
            }
        }
    }
    
    func save(){
        let userData = NSKeyedArchiver.archivedData(withRootObject: self)
        UserDefaults().set(userData, forKey: "PiSettings")
        print(string())
    }
    
    func deleteAll(){
        if let bundle = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundle)
        }
    }

    // MARK: NSCoding
    required convenience init?(coder aDecoder: NSCoder) {
        
        self.init()
        
        guard let servers = aDecoder.decodeObject(forKey: "servers") as? [PiServer] else {
            os_log("Unable to decode `servers` for a PiSettings object.", log: OSLog.default, type: .debug)
            return nil
        }
        self.servers = servers
        guard let selectedServer = aDecoder.decodeObject(forKey: "selectedServer") as? PiServer? else {
            os_log("Unable to decode `selectedServer` for a PiSettings object.", log: OSLog.default, type: .debug)
            return nil
        }
        self.selectedServer = selectedServer
    }
    
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(servers, forKey: "servers")
        aCoder.encode(selectedServer, forKey: "selectedServer")
    }
    
}


/**
 Class representing a server
 */
class PiServer: NSObject, NSCoding {
    
    // MARK: Properties
    
    /// Name
    var name: String
    
    /// Host name
    var hostName: String
    
    /// Port number
    var port: UInt
    
    /// User-defined commands
    var userCommands: PiUserCommands

    /// True if the user wants a textfield for sending commands to the server
    var anyCommand: Bool
    
    /// GPIO
    var gpio: PiGPIO

    
    /**
     Initialization of the command.
     
     - Parameters:
     - buttonName: the name the button will display
     
     - Returns: An object representing a user-defined command
     */
    // MARK: Initialization
    init(name: String, hostName: String, port: UInt) {
        self.name = name
        self.hostName = hostName
        self.port = port
        self.userCommands = PiUserCommands()
        self.anyCommand = false
        self.gpio = PiGPIO()
    }

    func string() -> String {
        var str = "Server:\n"
        str.append("    name: \(name)\n")
        str.append("    hostName: \(hostName)\n")
        str.append("    port: \(port)\n")
        let commandstr = userCommands.string()
        commandstr.enumerateLines{ (line, stop) in
                str.append("    \(line)\n")
        }
        str.append("    anyCommand: \(anyCommand)\n")
        let gpiostr = gpio.string()
        gpiostr.enumerateLines{ (line, stop) in
            str.append("    \(line)\n")
        }
        return str
    }

    // MARK: NSCoding
    required convenience init?(coder aDecoder: NSCoder) {
        
        guard let name = aDecoder.decodeObject(forKey: "name") as? String else {
            os_log("Unable to decode `name` for a PiServer object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        guard let hostName = aDecoder.decodeObject(forKey: "hostName") as? String else {
            os_log("Unable to decode `hostName` for a PiServer object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        guard let port = aDecoder.decodeObject(forKey: "port") as? UInt else {
            os_log("Unable to decode `port` for a PiServer object.", log: OSLog.default, type: .debug)
            return nil
        }
        // Must call designated initializer.
        self.init(name: name, hostName: hostName, port: port)
        
        guard let userCommands = aDecoder.decodeObject(forKey: "userCommands") as? PiUserCommands else {
            os_log("Unable to decode `userCommands` for a PiServer object.", log: OSLog.default, type: .debug)
            return nil
        }
        self.userCommands = userCommands

        guard let anyCommand = aDecoder.decodeObject(forKey: "anyCommand") as? UInt else {
            os_log("Unable to decode `anyCommand` for a PiServer object.", log: OSLog.default, type: .debug)
            return nil
        }
        self.anyCommand = Bool(anyCommand as NSNumber)
        
        guard let gpio = aDecoder.decodeObject(forKey: "gpio") as? PiGPIO else {
            os_log("Unable to decode `gpio` for a PiServer object.", log: OSLog.default, type: .debug)
            return nil
        }
        self.gpio = gpio
    }
    
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(hostName, forKey: "hostName")
        aCoder.encode(port, forKey: "port")
        aCoder.encode(userCommands, forKey: "userCommands")
        aCoder.encode(UInt(NSNumber(value:anyCommand)), forKey: "anyCommand")
        aCoder.encode(gpio, forKey: "gpio")
    }
    
}


/**
 Class representing User-defined commands
 */
class PiUserCommands: NSObject, NSCoding {
    
    /// Is the master switch on?
    var isOn: Bool = false
    
    /// List of commands
    var commands = [PiCommand]()

    func string() -> String {
        var str = "User commands:\n"
        str.append("    isOn: \(isOn)\n")
        str.append("    commands:\n")
        for command in commands {
            str.append("        \(command.string())\n")
        }
        return str
    }

    // MARK: NSCoding
    required convenience init?(coder aDecoder: NSCoder) {
        
        self.init()
        
        guard let isOn = aDecoder.decodeObject(forKey: "isOn") as? UInt else {
            os_log("Unable to decode `isOn` for a PiUserCommands object.", log: OSLog.default, type: .debug)
            return nil
        }
        self.isOn = Bool(isOn as NSNumber)
        
        guard let commands = aDecoder.decodeObject(forKey: "commands") as? [PiCommand] else {
            os_log("Unable to decode `pins` for a PiUserCommands object.", log: OSLog.default, type: .debug)
            return nil
        }
        self.commands = commands
    }
    
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(UInt(NSNumber(value:isOn)), forKey: "isOn")
        aCoder.encode(commands, forKey: "commands")
    }
    
}


/**
 Class representing a user-defined command that will be sent to the server
 */
class PiCommand: NSObject, NSCoding {

    // MARK: Properties
    
    /// Name that the button will display
    var buttonName: String
    
    /// Command that will be sent to the server
    var command: String
    
    /**
        Initialization of the command.
     
        - Parameters:
            - buttonName: the name the button will display
     
        - Returns: An object representing a user-defined command
     */
    // MARK: Initialization
    init(buttonName: String) {
        self.buttonName = buttonName
        self.command = buttonName.lowercased()
    }

    func string() -> String {
        return "Command (buttonName: \(buttonName), command: \(command))"
    }

    // MARK: NSCoding
    required convenience init?(coder aDecoder: NSCoder) {
        
        guard let buttonName = aDecoder.decodeObject(forKey: "buttonName") as? String else {
            os_log("Unable to decode `buttonName` for a PiCommand object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        // Must call designated initializer.
        self.init(buttonName: buttonName)
        
        guard let command = aDecoder.decodeObject(forKey: "command") as? String else {
            os_log("Unable to decode `command` for a PiCommand object.", log: OSLog.default, type: .debug)
            return nil
        }
        self.command = command
    }
    
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(buttonName, forKey: "buttonName")
        aCoder.encode(command, forKey: "command")
    }
    
}


/**
 Class representing GPIO preferences
 */
class PiGPIO: NSObject, NSCoding {
    
    /// Is the master switch on?
    var isOn: Bool = false

    /// List of pins
    var pins = [PiGPIOPin]()
    
    func string() -> String {
        var str = "GPIO:\n"
        str.append("    isOn: \(isOn)\n")
        str.append("    pins:\n")
        for pin in pins {
            str.append("        \(pin.string())\n")
        }
        return str
    }

    // MARK: NSCoding
    required convenience init?(coder aDecoder: NSCoder) {
        
        self.init()
        
        guard let isOn = aDecoder.decodeObject(forKey: "isOn") as? UInt else {
            os_log("Unable to decode `isOn` for a PiGPIO object.", log: OSLog.default, type: .debug)
            return nil
        }
        self.isOn = Bool(isOn as NSNumber)

        guard let pins = aDecoder.decodeObject(forKey: "pins") as? [PiGPIOPin] else {
            os_log("Unable to decode `pins` for a PiGPIO object.", log: OSLog.default, type: .debug)
            return nil
        }
        self.pins = pins
    }
    
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(UInt(NSNumber(value:isOn)), forKey: "isOn")
        aCoder.encode(pins, forKey: "pins")
    }
    
}


/**
    Class representing GPIO pins
*/
class PiGPIOPin: NSObject, NSCoding {
    
    // MARK: Properties
    
    /// The pin number (must be between 2 and 28)
    var number: UInt
    
    /// The name that you want to give to the pin, e.g. `Temperature sensor`
    var name: String
    
    /// The type of the pin: input or output (default)
    var type: PiPinType
    
    /// Polling frequency for input pins (in seconds)
    var polling: UInt

    /**
        Initialization of the GPIO pin.
     
        - Parameters:
            - number: the pin number
     
        - Returns: An object representing a GPIO pin
    */
    // MARK: Initialization
    init(number: UInt) {
        if number < 2 {
            self.number = 2
        } else {
            if number > 27 {
                self.number = 27
            } else {
                self.number = number
            }
        }
        self.name = "GPIO-\(self.number)"
        self.type = .output
        self.polling = 5
    }
    
    func string() -> String {
        return "GPIO Pin (number: \(number), name: \(name), type: \(type), polling: \(polling))"
    }
    
    // MARK: NSCoding
    required convenience init?(coder aDecoder: NSCoder) {
        
        guard let number = aDecoder.decodeObject(forKey: "number") as? UInt else {
            os_log("Unable to decode `number` for a PiGPIOPin object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        // Must call designated initializer.
        self.init(number: number)

                guard let name = aDecoder.decodeObject(forKey: "name") as? String else {
            os_log("Unable to decode `name` for a PiGPIOPin object.", log: OSLog.default, type: .debug)
            return nil
        }
        self.name = name

        let typeHash = aDecoder.decodeInteger(forKey: "pinType")
        self.type = PiPinType(fromNumber: typeHash)
        
        guard let polling = aDecoder.decodeObject(forKey: "polling") as? UInt else {
            os_log("Unable to decode `polling` for a PiGPIOPin object.", log: OSLog.default, type: .debug)
            return nil
        }
        self.polling = polling
    }
        
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(number, forKey: "number")
        aCoder.encode(type.toInt(), forKey: "pinType")
        aCoder.encode(polling, forKey: "polling")
    }
}


enum PiPinType {
    // types of GPIO pins
    case input
    case output

    init(fromNumber: Int) {
        if fromNumber == 0 {
            self = .input
        } else {
            self = .output
        }
    }
    
    func toInt() -> Int {
        switch self {
        case .input:
            return 0
        case .output:
            return 1
        }
    }

}
