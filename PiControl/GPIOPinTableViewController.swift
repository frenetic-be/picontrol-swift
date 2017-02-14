//
//  GPIOPinTableViewController.swift
//  PiControl
//
//  Created by Julien Spronck on 13/02/2017.
//  Copyright © 2017 Julien Spronck. All rights reserved.
//

import UIKit

protocol GPIOPinProtocol {
    func reloadData()
}

class GPIOPinTableViewController: UITableViewController, UITextFieldDelegate {

    // MARK: Properties
    var pin = PiGPIOPin(number: 2)
    var existingPins = [UInt]()
    var nextAvailablePin: UInt = 2
    var delegate: GPIOPinProtocol?
    
    @IBOutlet weak var pinNumberTextField: UITextField!
    @IBOutlet weak var pinNameTextField: UITextField!
    @IBOutlet weak var pinType: UISegmentedControl!
    @IBOutlet weak var pollingTextField: UITextField!
    @IBOutlet weak var pollingLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        pinNumberTextField.text = "\(pin.number)"
        pinNameTextField.text = pin.name
        if pin.type == .input {
            pinType.selectedSegmentIndex = 0
            pollingLabel.isEnabled = true
            pollingTextField.isEnabled = true
        } else {
            pinType.selectedSegmentIndex = 1
            pollingLabel.isEnabled = false
            pollingTextField.isEnabled = false
        }
        pollingTextField.text = "\(pin.polling)"
        pinNumberTextField.delegate = self
        pinNameTextField.delegate = self
        pollingTextField.delegate = self
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
        return 2
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
    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
 
    // MARK: TextFieldDelegate
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case pinNumberTextField:
            var pinNumber = UInt(pinNumberTextField.text ?? "2")!
            if pinNumber < 2 || pinNumber > 27 || existingPins.contains(pinNumber){
                pinNumber = nextAvailablePin
                pinNumberTextField.text = "\(pinNumber)"
            }
            pin.number = pinNumber
            let regex = try! NSRegularExpression(pattern: "^GPIO-([2-9]|1\\d|2[0-7])$", options: [])
            let match = regex.matches(in: pin.name, options: [], range: NSRange(location: 0, length: pin.name.characters.count))
            if match.count > 0 {
                pin.name = "GPIO-\(pinNumber)"
                pinNameTextField.text = pin.name
                delegate?.reloadData()
            }
        case pinNameTextField:
            pin.name = pinNameTextField.text ?? "GPIO-\(pin.number)"
            delegate?.reloadData()
        case pollingTextField:
            pin.polling = UInt(pollingTextField.text ?? "5")!
        default:
            return
        }
    }
    
    // MARK: Actions
    @IBAction func pinTypeHasChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            // Input
            pollingLabel.isEnabled = true
            pollingTextField.isEnabled = true
            pin.type = .input
        } else {
            // Output
            pollingLabel.isEnabled = false
            pollingTextField.isEnabled = false
            pin.type = .output
        }
    }

}
