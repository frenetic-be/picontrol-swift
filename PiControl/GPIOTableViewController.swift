//
//  GPIOTableViewController.swift
//  PiControl
//
//  Created by Julien Spronck on 13/02/2017.
//  Copyright © 2017 Julien Spronck. All rights reserved.
//

import UIKit
import os.log

protocol GPIOProtocol {
    // Protocol to send data back to the ServerConfigTableViewController
    func changedGPIOIsOn(isOn: Bool)
    func changedGPIOPins(pins: [PiGPIOPin])
}

class GPIOTableViewController: UITableViewController, GPIOPinProtocol, ConfigServerResponseProtocol {

    // MARK: Properties
    var isOn = false
    var pins = [PiGPIOPin]()
    var selectedRow: IndexPath?
    var delegate: GPIOProtocol?
    var hostName = ""
    var portNumber: UInt = 3000
    var serverResponse = ""
    
    @IBOutlet var GPIOTableView: UITableView!
    @IBOutlet weak var addPinButton: UIBarButtonItem!    

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.

        navigationItem.setRightBarButtonItems([addPinButton, editButtonItem], animated: false)
        for item in navigationItem.rightBarButtonItems! {
            item.isEnabled = isOn
        }
        
    }

    override func viewWillAppear(_ animated: Bool) {
        
        // Set accessibility identifiers
        self.navigationController?.navigationBar.accessibilityIdentifier = "GPIONavBar"
        
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
        return 4
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
        case 2:
            if isOn {
                return 1
            }
            return 0
        case 3:
            if isOn {
                return 1
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
        case 2:
            cellID = "GPIOConfigTableViewCell"
//            let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? GPIOConfigTableViewCell  else {
                fatalError("The dequeued cell is not an instance of GPIOConfigTableViewCell.")
            }

            cell.separatorInset = UIEdgeInsetsMake(0, cell.frame.width/2, 0, cell.frame.width/2)
            if hostName == "" || pins.count == 0 {
                cell.configButton.isEnabled = false
            } else {
                cell.configButton.isEnabled = true
            }
            return cell
        case 3:
            cellID = "GPIOConfigStatusTableViewCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
            cell.layer.backgroundColor = UIColor.clear.cgColor
            cell.textLabel?.text = serverResponse
            cell.textLabel?.backgroundColor = UIColor.clear
            return cell
        default:
            fatalError("Unknown section")
        }
    }


    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        if indexPath.section == 1 {
            return true
        }
        return false
    }

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if indexPath.section == 1 {
                // Delete the row from the data source
                pins.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                delegate?.changedGPIOPins(pins: pins)
                tableView.reloadData()
            }
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
 

    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let itemToMove = pins[fromIndexPath.row]
        pins.remove(at: fromIndexPath.row)
        pins.insert(itemToMove, at: to.row)
        delegate?.changedGPIOPins(pins: pins)
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
            destination.nextAvailablePin = min(destination.pin.number, nextAvailablePin()!)
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
        delegate?.changedGPIOIsOn(isOn: isOn)
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
            delegate?.changedGPIOPins(pins: pins)
        }
    }
    
    @IBAction func configureGPIO(_ sender: UIButton) {
        let socket = GPIOConfigSocket(host: hostName, port: portNumber)
        socket.delegate = self
        socket.configureGPIO(pins: pins)
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
    
    // MARK: GPIOPinProtocol
    
    func reloadData() {
        if let row = selectedRow {
            GPIOTableView.reloadRows(at: [row], with: .none)
        }
        delegate?.changedGPIOPins(pins: pins)
    }

    // MARK: ConfigServerResponseProtocol
    
    func useServerResponse(response: Any) {
        serverResponse = "\(response)"
        if let resp = response as? [Any] {
            if resp.count == 1 {
                serverResponse = "\(resp[0])"
            }
        }
        let indexPath = IndexPath(row: 0, section: 3)
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
}
