//
//  UserCommandTableViewController.swift
//  PiControl
//
//  Created by Julien Spronck on 15/02/2017.
//  Copyright © 2017 Julien Spronck. All rights reserved.
//

import UIKit

protocol UserCommandProtocol {
    func reloadData()
}

class UserCommandTableViewController: UITableViewController, UITextFieldDelegate {
    
    // MARK: Properties
    var command = PiCommand(buttonName: "")
    var delegate: UserCommandProtocol?

    @IBOutlet weak var buttonNameTextField: UITextField!
    @IBOutlet weak var commandStringTextField: UITextField!
    @IBOutlet weak var commandHasArgumentsSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        buttonNameTextField.delegate = self
        commandStringTextField.delegate = self
        
        buttonNameTextField.text = command.buttonName
        commandStringTextField.text = command.command
        commandHasArgumentsSwitch.isOn = command.commandHasArguments
        
        if command.command.isEmpty {
            disableBackButton()
        }
        
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
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 3
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
    /*
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        print("leaving")
    }
     */
 
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case buttonNameTextField:
            commandStringTextField.becomeFirstResponder()
        case commandStringTextField:
            dismissKeyboard()
        default:
            return true
        }
        return true
    }
    
    // MARK: - Actions
    
    @IBAction func buttonHasChanged(_ sender: UITextField) {
        command.buttonName = sender.text ?? ""
        delegate?.reloadData()
        if command.command.isEmpty {
            if command.buttonName.isEmpty {
                self.title = "New Command"
            } else {
                self.title = command.buttonName
            }
        }
    }

    @IBAction func commandHasChanged(_ sender: UITextField) {
        command.command = sender.text ?? ""
        if command.command.isEmpty {
            disableBackButton()
            showAlert(message: "The command cannot be empty")
        } else {
            enableBackButton()
        }
        delegate?.reloadData()
    }

    @IBAction func commandIsBeingEdited(_ sender: UITextField) {
        if (sender.text ?? "").isEmpty {
            disableBackButton()
        } else {
            enableBackButton()
        }
    }
    
    
    @IBAction func hasArgumentsChanged(_ sender: UISwitch) {
        command.commandHasArguments = sender.isOn
    }
    
    func showAlert(message: String, title:String="Error") {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)

        self.present(alertController, animated: true, completion: nil)
    }
    
    func disableBackButton(){
        // navigationController?.navigationBar.isUserInteractionEnabled = false
        // navigationController?.navigationBar.tintColor = UIColor.lightGray
        navigationItem.hidesBackButton = true
        if command.buttonName.isEmpty {
            self.title = "New Command"
        } else {
            self.title = command.buttonName
        }
    }
    func enableBackButton(){
        // navigationController?.navigationBar.isUserInteractionEnabled = true
        // navigationController?.navigationBar.tintColor = self.view.tintColor
        navigationItem.hidesBackButton = false
        self.title = ""
    }

}
