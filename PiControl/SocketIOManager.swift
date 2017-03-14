//
//  SocketIOManager.swift
//  SocketChat
//
//  Created by Julien Spronck on 09/02/2017.
//  Copyright © 2017 AppCoda. All rights reserved.
//

import UIKit

protocol ServerResponseProtocol {

    var canceledConnection: Bool { get set }
    
    func useServerResponse(response: Any)
    func updateGPIOSwitch(data: Any)
    func updateGPIOSwitches(data: Any)
    
    func hasConnected()
    func failedToConnect()
    func hasDisconnected()
    func failedToConfigureGPIO()
    
    func checkConnectionCode()
    func removeConnectionCode()
    func addConnectionCode()
    
}

protocol ConfigServerResponseProtocol {
    func useServerResponse(response: Any)
}

class SocketIOManager: NSObject {
    
    var host: String
    var port: UInt
    var socket: SocketIOClient
    var isConnected = false
    var connecting = false
//    var timeout: Double = 10
    var delegate: ServerResponseProtocol?
    
    init(host: String, port: UInt){
        self.host = host
        self.port = port
        self.socket = SocketIOClient(socketURL: URL(string: "\(host):\(port)")!)
        super.init()
        socket.on("connect") {data, ack in
            self.delegate?.checkConnectionCode()
        }
        socket.on("check_connection_response") {data, ack in
            if let validEntry = data[0] as? Bool {
                if validEntry {
                    self.isConnected = true
                    self.delegate?.hasConnected()
                    self.connecting = false
                    return
                }
            }
            // on unsuccessful connection attempt, remove hostname from UserDefault ConnectionCodes if it exists
            if !(self.delegate?.canceledConnection ?? false) {
                // the user didn't press cancel in the alert dialog but entered the wrong code
                self.delegate?.removeConnectionCode()
                self.delegate?.checkConnectionCode()
            } else {
                // the user pressed cancel in the alert dialog but entered the wrong code
                self.closeConnection()
            }
            self.connecting = false
        }
        socket.on("error") {data, ack in
            // self.isConnected = false
            print("Socket error: ", data, ack)
            if data.count > 0, let resp = data[0] as? String {
                if resp.hasPrefix("Tried") && resp.hasSuffix("when not connected") {
                    self.isConnected = false
                }
            }
            if !self.isConnected {
                self.delegate?.useServerResponse(response: "Not connected")
            }
            // self.delegate?.useServerResponse(response: "Socket Error")
        }
        socket.on("disconnect") {data, ack in
            self.isConnected = false
            self.delegate?.hasDisconnected()
        }
        socket.on("response") {data, ack in
            self.delegate?.useServerResponse(response: data)
        }
        socket.on("gpio_has_changed") {data, ack in
            self.delegate?.updateGPIOSwitch(data: data)
        }
        socket.on("gpio_not_configured") {data, ack in
            self.delegate?.failedToConfigureGPIO()
        }
        socket.on("response_gpio_get_all") {data, ack in
            self.delegate?.updateGPIOSwitches(data: data)
        }
        socket.on("response_gpio_get") {data, ack in
            self.delegate?.updateGPIOSwitch(data: data)
        }
    }
    
    func establishConnection() {
        if connecting {
            return
        }
        connecting = true
        self.delegate?.canceledConnection = false
        socket.connect(timeoutAfter: 10) {
            self.delegate?.failedToConnect()
        }
        delegate?.useServerResponse(response: "Connecting ...")
    }
    
    
    func closeConnection() {
        socket.disconnect()
        delegate?.useServerResponse(response: "Disconnecting ...")
    }

    func checkConnection(code: String){
        self.socket.emit("check_connection", code)
    }
    
    func defineOnEvents(message: String, completionHandler: @escaping (_ data: Any) -> Void) -> Void {
        socket.on(message) { ( dataArray, ack) -> Void in
                completionHandler(dataArray[0])
        }
    }
    
    func sendCommand(command: String) -> Void {
        if isConnected {
            socket.emit("execute", command)
        }
    }

    func setGPIO(pin: Int, value: Bool) -> Void {
        if isConnected {
            let intvalue = value ? 1 : 0
            let data: String = "\(pin):\(intvalue)"
            socket.emit("gpio_set", data)
        }
    }

    func getGPIO(pin: Int) -> Void {
        if isConnected {
            let data: String = "\(pin)"
            socket.emit("gpio_get", data)
        }
    }
    
    func getAllGPIO() -> Void {
        if isConnected {
            socket.emit("gpio_get_all")
        }
    }
    
    func startProbingInputPins(){
        self.socket.emit("start_probing_input")
    }
    
}

class GPIOConfigSocket: NSObject {
    
    var host: String
    var port: UInt
    var socket: SocketIOClient
    var isConnected = false
    var gpioPins = [String: String]()
    var delegate: ConfigServerResponseProtocol?
    
    init(host: String, port: UInt){
        self.host = host
        self.port = port
        self.socket = SocketIOClient(socketURL: URL(string: "\(host):\(port)")!)
        super.init()
        socket.on("connect") {data, ack in
            self.socket.emit("gpio_configure", self.gpioPins)
            self.delegate?.useServerResponse(response: "Sending GPIO data")
        }
        socket.on("response_gpio_configure") {data, ack in
            self.closeConnection()
            self.delegate?.useServerResponse(response: "Successfully configured")
        }
    }
    
    func configureGPIO(pins: [PiGPIOPin]) {
        for pin in pins {
//            print(pin.string())
            gpioPins["\(pin.number)"] = "\(pin.type),\(pin.polling)"
        }
        socket.connect(timeoutAfter: 10) {
            self.delegate?.useServerResponse(response: "Failed to configure:\nCould not connect to server")
        }
        delegate?.useServerResponse(response: "Connecting ...")
    }
    
    
    func closeConnection() {
        socket.disconnect()
    }
    
}
