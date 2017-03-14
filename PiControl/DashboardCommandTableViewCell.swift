//
//  DashboardCommandTableViewCell.swift
//  PiControl
//
//  Created by Julien Spronck on 15/02/2017.
//  Copyright © 2017 Julien Spronck. All rights reserved.
//

import UIKit

class DashboardCommandTableViewCell: UITableViewCell {

    // MARK: Properties
    
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var centralButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    
    var leftCommand = ""
    var centralCommand = ""
    var rightCommand = ""
    var socket: SocketIOManager?
    var parentView: UITableViewController?
    var leftHasArguments = false
    var centralHasArguments = false
    var rightHasArguments = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        leftButton.layer.borderWidth = 1
        centralButton.layer.borderWidth = 1
        rightButton.layer.borderWidth = 1
        leftButton.layer.cornerRadius = 5
        centralButton.layer.cornerRadius = 5
        rightButton.layer.cornerRadius = 5
//        let textColor = leftButton.titleColor(for: .normal) ?? UIColor.white
        leftButton.layer.borderColor = UIColor.clear.cgColor
        centralButton.layer.borderColor = UIColor.clear.cgColor
        rightButton.layer.borderColor = UIColor.clear.cgColor
        self.layer.backgroundColor = UIColor.clear.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: Actions
    
    func alertArguments(theCommand: String) {
        // Ask for arguments
        
        let alertController = UIAlertController(title: "Command arguments", message: "What are the arguments for this command?", preferredStyle: .alert)
        
        alertController.addTextField(configurationHandler: { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter all arguments separated by a space"
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in

        }
        alertController.addAction(cancelAction)
        
        let OKAction = UIAlertAction(title: "OK", style: .default) { action in
            let args = alertController.textFields?[0].text ?? ""
            self.socket?.sendCommand(command: "\(theCommand) \(args)")
        }
        alertController.addAction(OKAction)
        
        self.parentView?.present(alertController, animated: true) {}
    }
    
    @IBAction func leftButtonPressed(_ sender: UIButton) {
        if !leftHasArguments {
            socket?.sendCommand(command: leftCommand)
        } else {
            alertArguments(theCommand: leftCommand)
        }
    }
    
    @IBAction func centralButtonPressed(_ sender: UIButton) {
        if !centralHasArguments {
            socket?.sendCommand(command: centralCommand)
        } else {
            alertArguments(theCommand: centralCommand)
        }
    }
    
    @IBAction func rightButtonPressed(_ sender: UIButton) {
        if !rightHasArguments {
            socket?.sendCommand(command: rightCommand)
        } else {
            alertArguments(theCommand: rightCommand)
        }
    }
    
    // MARK: Private methods
    func setButtons(commands: [PiCommand]){
        switch commands.count {
        case 0:
            return
        case 1:
            leftButton.isHidden = true
            rightButton.isHidden = true
            centralButton.isHidden = false
            centralButton.setTitle(commands[0].buttonName, for: .normal)
            centralCommand = commands[0].command
            leftHasArguments = false
            rightHasArguments = false
            centralHasArguments = commands[0].commandHasArguments
        case 2:
            leftButton.isHidden = false
            rightButton.isHidden = false
            centralButton.isHidden = true
            leftButton.setTitle(commands[0].buttonName, for: .normal)
            leftCommand = commands[0].command
            rightButton.setTitle(commands[1].buttonName, for: .normal)
            rightCommand = commands[1].command
            leftHasArguments = commands[0].commandHasArguments
            rightHasArguments = commands[1].commandHasArguments
            centralHasArguments = false
        case 3:
            leftButton.isHidden = false
            rightButton.isHidden = false
            centralButton.isHidden = false
            leftButton.setTitle(commands[0].buttonName, for: .normal)
            leftCommand = commands[0].command
            centralButton.setTitle(commands[1].buttonName, for: .normal)
            centralCommand = commands[1].command
            rightButton.setTitle(commands[2].buttonName, for: .normal)
            rightCommand = commands[2].command
            leftHasArguments = commands[0].commandHasArguments
            rightHasArguments = commands[1].commandHasArguments
            centralHasArguments = commands[2].commandHasArguments
        default:
            return
        }

    }

}
