//
//  CommandsTableViewController.swift
//  PiControl
//
//  Created by Julien Spronck on 13/02/2017.
//  Copyright © 2017 Julien Spronck. All rights reserved.
//

    
import UIKit
import os.log

protocol UserCommandsProtocol {
    // Protocol to send data back to the ServerConfigTableViewController
    func changedCommandsIsOn(isOn: Bool)
    func changedCommands(commands: [PiCommand])
}

class CommandsTableViewController: UITableViewController, UserCommandProtocol {
    
    // MARK: Properties
    var isOn = false
    var commands = [PiCommand]()
    var selectedRow: IndexPath?
    var delegate: UserCommandsProtocol?
    
    @IBOutlet var CommandsTableView: UITableView!
    @IBOutlet weak var addCommandButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        
        navigationItem.setRightBarButtonItems([addCommandButton, editButtonItem], animated: false)
        for item in navigationItem.rightBarButtonItems! {
            item.isEnabled = isOn
        }
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
            cellID = "CommandsMasterSwitchTableViewCell"
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? MasterSwitchTableViewCell  else {
                fatalError("The dequeued cell is not an instance of CommandsMasterSwitchTableViewCell.")
            }
            cell.label.text = "User-defined commands"
            cell.switch.isOn = isOn
            return cell
        case 1:
            cellID = "UserCommandsTableViewCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
            
            let command = commands[indexPath.row]
            if let label = cell.textLabel {
                if command.buttonName.isEmpty {
                    label.text = "New button"
                } else {
                    label.text = command.buttonName
                }
            }
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
            if indexPath.section == 1 {
                // Delete the row from the data source
                commands.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                delegate?.changedCommands(commands: commands)
            }
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let itemToMove = commands[fromIndexPath.row]
        commands.remove(at: fromIndexPath.row)
        commands.insert(itemToMove, at: to.row)
        delegate?.changedCommands(commands: commands)
    }
    
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        if indexPath.section == 0 {
            return false
        }
        return true
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier ?? "" {
        case "ShowCommand":
            guard let destination = segue.destination as? UserCommandTableViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            guard let selectedCell = sender as? UITableViewCell else {
                fatalError("Unexpected sender: \(sender)")
            }
            guard let indexPath = tableView.indexPath(for: selectedCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            selectedRow = indexPath
            destination.delegate = self
            destination.command = commands[indexPath.row]

        default:
            //            fatalError("Unexpected Segue Identifier; \(segue.identifier)")
            return
        }
    }
    
    
    @IBAction func toggleMainSwitch(_ sender: UISwitch) {
        isOn = sender.isOn
        //        addPinButton.isEnabled = isOn
        //        editPinsButton.isEnabled = isOn
        for item in navigationItem.rightBarButtonItems! {
            item.isEnabled = isOn
        }
        delegate?.changedCommandsIsOn(isOn: isOn)
        CommandsTableView.reloadData()
    }
    
    @IBAction func newCommand(_ sender: UIBarButtonItem) {
        // Add a command to the commands array
        let newCommand = PiCommand(buttonName: "")
        commands.append(newCommand)
        CommandsTableView.reloadData()
        
        // select the new command and go the detail scene
        selectedRow = IndexPath(row: commands.count-1, section: 1)
        performSegue(withIdentifier: "ShowCommand", sender: CommandsTableView.cellForRow(at: selectedRow!))
    }
    
    
    func reloadData() {
        if let row = selectedRow {
            CommandsTableView.reloadRows(at: [row], with: .none)
        }
        for cmd in commands {
            print(cmd.string())
        }
        delegate?.changedCommands(commands: commands)
    }
        
}
