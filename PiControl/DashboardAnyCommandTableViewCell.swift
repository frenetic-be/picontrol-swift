//
//  DashboardAnyCommandTableViewCell.swift
//  PiControl
//
//  Created by Julien Spronck on 15/02/2017.
//  Copyright © 2017 Julien Spronck. All rights reserved.
//

import UIKit

class DashboardAnyCommandTableViewCell: UITableViewCell, UITextFieldDelegate {

    // MARK: Properties
    
    @IBOutlet weak var commandTextField: UITextField!
    
    var socket: SocketIOManager?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        commandTextField.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func sendCommandToServer(){
        let command = commandTextField.text ?? ""
        if !command.isEmpty {
            socket?.sendCommand(command: command)
            commandTextField.text = ""
        }
        self.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendCommandToServer()
        return true
    }

    @IBAction func sendCommand(_ sender: UIButton) {
        sendCommandToServer()
    }
}
