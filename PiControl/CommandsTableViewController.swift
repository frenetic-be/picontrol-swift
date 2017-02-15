//
//  CommandsTableViewController.swift
//  PiControl
//
//  Created by Julien Spronck on 13/02/2017.
//  Copyright © 2017 Julien Spronck. All rights reserved.
//

import UIKit
import os.log

class CommandsTableViewController: UITableViewController {
    
    // MARK: Properties
    var isOn = false
    var commands = [PiCommand]()
    var backTitle = ""
    
    @IBOutlet var theTableView: UITableView!
    @IBOutlet weak var addCommandButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.navigationItem.leftBarButtonItem?.title = "< \(backTitle)"
        addCommandButton.isEnabled = isOn

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return nil
        case 1:
            if isOn{
                return "User-defined commands"
            }
            return nil
        default:
            return nil
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section {
        case 0:
            return 1
        case 1:
            if isOn {
                return commands.count
            }
            return 0
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cellID: String
        switch indexPath.section {
        case 0:
            cellID = "MasterSwitchTableViewCell"
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? MasterSwitchTableViewCell  else {
                fatalError("The dequeued cell is not an instance of MasterSwitchTableViewCell.")
            }
            cell.label.text = "User commands"
            cell.switch.isOn = isOn
            return cell
        case 1:
            cellID = "UserCommandTableViewCell"
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? UserCommandTableViewCell else {
                fatalError("The dequeued cell is not an instance of UserCommandTableViewCell.")
            }
            let command = commands[indexPath.row]
            cell.buttonNameTextField.text = command.buttonName
            cell.commandStringTextField.text = command.command
            return cell
        default:
            fatalError("Unknown section")
        }
    }


    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        if indexPath.section == 0 {
            return false
        }
        return true
    }

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            commands.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
 

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
        
        guard let button = sender as? UIBarButtonItem, let bbutton = navigationItem.leftBarButtonItem, button === bbutton else {
            os_log("The back button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
        saveCommands()
    }
 
    
    
    @IBAction func toggleMainSwitch(_ sender: UISwitch) {
        isOn = sender.isOn
        addCommandButton.isEnabled = isOn
        theTableView.reloadData()
    }

    @IBAction func newCommand(_ sender: UIBarButtonItem) {
        let newCmd = PiCommand(buttonName: "")
        commands.append(newCmd)
        saveCommands()
        theTableView.reloadData()
    }
    
    func saveCommands(){
        for (index, item) in theTableView.visibleCells.enumerated(){
            if let cell = item as? UserCommandTableViewCell {
                commands[index-1].buttonName = cell.buttonNameTextField.text ?? ""
                commands[index-1].command = cell.commandStringTextField.text ?? ""
            }
        }
    }
}
