//
//  GPIOTableViewController.swift
//  PiControl
//
//  Created by Julien Spronck on 13/02/2017.
//  Copyright © 2017 Julien Spronck. All rights reserved.
//

import UIKit
import os.log

class GPIOTableViewController: UITableViewController, GPIOPinProtocol {

    // MARK: Properties
    var isOn = false
    var pins = [PiGPIOPin]()
    var backTitle = ""
    var selectedRow: IndexPath?
    
    @IBOutlet var GPIOTableView: UITableView!
    @IBOutlet weak var addPinButton: UIBarButtonItem!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.navigationItem.leftBarButtonItem?.title = "< \(backTitle)"
        addPinButton.isEnabled = isOn
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
                return "GPIO pins"
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
                return pins.count
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
            cellID = "GPIOMasterSwitchTableViewCell"
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? MasterSwitchTableViewCell  else {
                fatalError("The dequeued cell is not an instance of GPIOMasterSwitchTableViewCell.")
            }
            cell.label.text = "GPIO"
            cell.switch.isOn = isOn
            return cell
        case 1:
            cellID = "GPIOPinsTableViewCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)

            let gpiopin = pins[indexPath.row]
            if let label = cell.textLabel {
                label.text = gpiopin.name
            }
            return cell
        default:
            fatalError("Unknown section")
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            pins.remove(at: indexPath.row)
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
        switch segue.identifier ?? "" {
        case "ShowGPIOPin":
            guard let destination = segue.destination as? GPIOPinTableViewController else {
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
            destination.pin = pins[indexPath.row]
            var pinNumbers = [UInt]()
            for pin in pins {
                if pin != destination.pin {
                    pinNumbers.append(pin.number)
                }
            }
            destination.existingPins = pinNumbers
            destination.nextAvailablePin = nextAvailablePin()!
        default:
//            fatalError("Unexpected Segue Identifier; \(segue.identifier)")
            return
        }
    }
    

    @IBAction func toggleMainSwitch(_ sender: UISwitch) {
        isOn = sender.isOn
        addPinButton.isEnabled = isOn
        GPIOTableView.reloadData()
    }

    @IBAction func newPin(_ sender: UIBarButtonItem) {
        if let nextNumber = nextAvailablePin() {
            let newPin = PiGPIOPin(number: nextNumber)
            pins.append(newPin)
            GPIOTableView.reloadData()
            if nextNumber == 27 {
                addPinButton.isEnabled = false
            }
        }
    }
    
    func nextAvailablePin() -> UInt? {
        var pinNumbers = [UInt]()
        for pin in pins {
            pinNumbers.append(pin.number)
        }
        var pinNumber: UInt = 2
        while pinNumbers.contains(pinNumber) && pinNumber < 28 {
            pinNumber += 1
        }
        if pinNumber < 28 {
            return pinNumber
        }
        return nil
    }
    
    
    func reloadData() {
        if let row = selectedRow {
            GPIOTableView.reloadRows(at: [row], with: .none)
        }
    }

}
