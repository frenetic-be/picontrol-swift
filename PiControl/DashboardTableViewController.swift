//
//  DashboardTableViewController.swift
//  PiControl
//
//  Created by Julien Spronck on 15/02/2017.
//  Copyright © 2017 Julien Spronck. All rights reserved.
//

import UIKit

class DashboardTableViewController: UITableViewController {

    var settings = PiSettings()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        settings.load()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let offHeight = CGFloat(0.1)
        let onHeight = CGFloat(18)
        let firstHeight = CGFloat(40)
        switch section {
        case 0:
            if let server = settings.selectedServer {
                if !server.userCommands.isOn {
                    return offHeight
                }
                return onHeight+firstHeight
            }
            return offHeight
        case 1:
            if let server = settings.selectedServer {
                if !server.anyCommand {
                    return offHeight
                }
                if !server.userCommands.isOn {
                    return firstHeight
                }
                return onHeight
            }
            return offHeight
        case 2:
            if let server = settings.selectedServer {
                if !server.gpio.isOn {
                    return offHeight
                }
                if !server.userCommands.isOn && !server.anyCommand {
                    return firstHeight
                }
                return onHeight
            }
            return offHeight
        default:
            return offHeight
        }
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let offHeight = CGFloat(0.1)
        let onHeight = CGFloat(18)
        switch section {
        case 0:
            if let server = settings.selectedServer {
                if !server.userCommands.isOn {
                    return offHeight
                }
                return onHeight
            }
            return offHeight
        case 1:
            if let server = settings.selectedServer {
                if !server.anyCommand {
                    return offHeight
                }
                return onHeight
            }
            return offHeight
        case 2:
            if let server = settings.selectedServer {
                if !server.gpio.isOn {
                    return offHeight
                }
                return onHeight
            }
            return offHeight
        default:
            return offHeight
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            if let server = settings.selectedServer {
                if !server.userCommands.isOn {
                    return ""
                }
                return "Pre-defined commands"
            }
            return ""
        case 1:
            if let server = settings.selectedServer {
                if !server.anyCommand {
                    return ""
                }
                return ""
            }
            return ""
        case 2:
            if let server = settings.selectedServer {
                if !server.gpio.isOn {
                    return ""
                }
                return "GPIO Pins"
            }
            return ""
        default:
            return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            if let server = settings.selectedServer {
                if !server.userCommands.isOn {
                    return 0
                }
                return Int(ceil(Double(server.userCommands.commands.count)/3))
            }
            return 0
        case 1:
            if let server = settings.selectedServer {
                if !server.anyCommand {
                    return 0
                }
                return 1
            }
            return 0
        case 2:
            if let server = settings.selectedServer {
                if !server.gpio.isOn {
                    return 0
                }
                return server.gpio.pins.count
            }
            return 0
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "DashboardCommandTableViewCell", for: indexPath) as? DashboardCommandTableViewCell  else {
                fatalError("The dequeued cell is not an instance of DashboardCommandTableViewCell.")
            }
            if let server = settings.selectedServer {
                let commands = server.userCommands.commands
                let nbuttons = commands.count
                let row = indexPath.row
                var subarray = [PiCommand]()
                for j in row*3...min(row*3+2, nbuttons-1){
                    subarray.append(commands[j])
                }
                cell.setButtons(commands: subarray)
                cell.layer.backgroundColor = UIColor.clear.cgColor
                cell.separatorInset = UIEdgeInsetsMake(0, cell.frame.width/2, 0, cell.frame.width/2);
            
            }
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "DashboardAnyCommandTableViewCell", for: indexPath) as? DashboardAnyCommandTableViewCell  else {
                fatalError("The dequeued cell is not an instance of DashboardAnyCommandTableViewCell.")
            }
            return cell
        case 2:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "DashboardGPIOTableViewCell", for: indexPath) as? DashboardGPIOTableViewCell  else {
                fatalError("The dequeued cell is not an instance of DashboardGPIOTableViewCell.")
            }
            if let server = settings.selectedServer {
                let pins = server.gpio.pins
                let row = indexPath.row
                let pin = pins[row]
                cell.GPIOLabel.text = pin.name
                cell.pinNumber = pin.number
            }
            return cell
        default:
            fatalError("Wrong section: \(indexPath.section)")
        }
    }

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
