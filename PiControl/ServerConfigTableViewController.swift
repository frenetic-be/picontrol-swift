//
//  ServerConfigTableViewController.swift
//  PiControl
//
//  Created by Julien Spronck on 13/02/2017.
//  Copyright © 2017 Julien Spronck. All rights reserved.
//

import UIKit
import os.log

class ServerConfigTableViewController: UITableViewController, UITextFieldDelegate, GPIOProtocol, UserCommandsProtocol {

    // MARK: Properties
    var currentServer = PiServer(name: "", hostName: "http://yourpi.local", port: 3000)

    @IBOutlet weak var serverNameTextField: UITextField!
    @IBOutlet weak var hostNameTextField: UITextField!
    @IBOutlet weak var portNumberTextField: UITextField!
    @IBOutlet weak var anyCommandSwitch: UISwitch!
    @IBOutlet weak var responseOnSwitch: UISwitch!
    
    @IBOutlet weak var savePiButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()

        serverNameTextField.delegate = self
        hostNameTextField.delegate = self
        portNumberTextField.delegate = self
        
        if currentServer.name.isEmpty {
            navigationItem.title = "New Pi"
            savePiButton.isEnabled = false
        } else {
            navigationItem.title = currentServer.name
            savePiButton.isEnabled = true
        }
        serverNameTextField.text = currentServer.name
        hostNameTextField.text = currentServer.hostName
        portNumberTextField.text = "\(currentServer.port)"
        anyCommandSwitch.isOn = currentServer.anyCommand
        responseOnSwitch.isOn = currentServer.responseOn
        
        // Tap anywhere to dismiss the keyboard
        self.hideKeyboardWhenTappedAround()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section {
            case 0:
                return 3
            case 1:
                return 4
            default:
                return 0
        }
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let segueID = segue.identifier ?? ""
        switch segueID {
        case "ShowUserCommands":
            guard let destination = segue.destination as? CommandsTableViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            destination.isOn = currentServer.userCommands.isOn
            destination.commands = currentServer.userCommands.commands
            destination.delegate = self

        case "ShowGPIO":
            guard let destination = segue.destination as? GPIOTableViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            destination.isOn = currentServer.gpio.isOn
            destination.pins = currentServer.gpio.pins
            destination.delegate = self
            destination.hostName = currentServer.hostName
            destination.portNumber = currentServer.port
        default:
            guard let button = sender as? UIBarButtonItem, button === savePiButton else {
                os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
                return
            }
            
            currentServer.name = serverNameTextField.text ?? ""
            currentServer.hostName = hostNameTextField.text ?? ""
            let portNumber = portNumberTextField.text ?? "3000"
            currentServer.port = UInt(portNumber)!
            currentServer.anyCommand = anyCommandSwitch.isOn
            currentServer.responseOn = responseOnSwitch.isOn
        }

    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case serverNameTextField:
            hostNameTextField.becomeFirstResponder()
        case hostNameTextField:
            portNumberTextField.becomeFirstResponder()
        case portNumberTextField:
            dismissKeyboard()
        default:
            return true
        }
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case serverNameTextField, hostNameTextField:
            if ((serverNameTextField.text?.isEmpty ?? true) || (hostNameTextField.text?.isEmpty ?? true)) {
                savePiButton.isEnabled = false
            }
            else {
                savePiButton.isEnabled = true
            }
        default:
            return
        }
    }

    // MARK: Actions
    @IBAction func unwindToServerConfig(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? CommandsTableViewController {
            currentServer.userCommands.commands = sourceViewController.commands
            currentServer.userCommands.isOn = sourceViewController.isOn
        } else if let sourceViewController = sender.source as? GPIOTableViewController {
            currentServer.gpio.pins = sourceViewController.pins
            currentServer.gpio.isOn = sourceViewController.isOn
        }
    }
    @IBAction func cancelNewPi(_ sender: UIBarButtonItem) {
        // Depending on style of presentation (modal or push presentation), this view controller needs to be dismissed in two different ways.
        let isPresentingInAddPiMode = presentingViewController is UITabBarController
        if isPresentingInAddPiMode {
            dismiss(animated: true, completion: nil)
        } else if let owningNavigationController = navigationController{
            owningNavigationController.popViewController(animated: true)
        } else {
            fatalError("The MealViewController is not inside a navigation controller.")
        }
    }

    // MARK: GPIOProtocol
    func changedGPIOIsOn(isOn: Bool) {
        currentServer.gpio.isOn = isOn
    }
    
    func changedGPIOPins(pins: [PiGPIOPin]) {
        currentServer.gpio.pins = pins
    }
    // MARK: UserCommandsProtocol
    func changedCommandsIsOn(isOn: Bool) {
        currentServer.userCommands.isOn = isOn
    }
    
    func changedCommands(commands: [PiCommand]) {
        currentServer.userCommands.commands = commands
    }
}
