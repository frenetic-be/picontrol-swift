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
    var availablePins = [UInt]()
    var currentIndex = 0
    var nextAvailablePin: UInt = 2
    var delegate: GPIOPinProtocol?
    
    @IBOutlet weak var pinNumberTextField: UITextField!
    @IBOutlet weak var pinNameTextField: UITextField!
    @IBOutlet weak var pinType: UISegmentedControl!
    @IBOutlet weak var pollingTextField: UITextField!
    @IBOutlet weak var pollingLabel: UILabel!
    @IBOutlet weak var pollingStepper: UIStepper!
    @IBOutlet weak var pinNumberStepper: UIStepper!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        availablePins = [UInt]()
        for index in 2...27 {
            if !existingPins.contains(UInt(index)) || pin.number == UInt(index){
                availablePins.append(UInt(index))
            }
        }
        if availablePins.count == 0 {
            pinNumberStepper.isEnabled = false
        } else {
            pinNumberStepper.isEnabled = true
            pinNumberStepper.minimumValue = 0
            pinNumberStepper.maximumValue = Double(availablePins.count-1)
            pinNumberStepper.value = Double(availablePins.index(of: pin.number)!)
        }
        
        pinNumberTextField.text = "\(pin.number)"
        
        pinNameTextField.text = pin.name
        if pin.type == .input {
            pinType.selectedSegmentIndex = 0
            pollingLabel.isEnabled = true
            pollingTextField.isEnabled = true
            pollingStepper.isEnabled = true
        } else {
            pinType.selectedSegmentIndex = 1
            pollingLabel.isEnabled = false
            pollingTextField.isEnabled = false
            pollingStepper.isEnabled = false
        }
        pollingTextField.text = "\(pin.polling)"
        pollingStepper.value = Double(pin.polling)
        pinNumberTextField.delegate = self
        pinNameTextField.delegate = self
        pollingTextField.delegate = self
        
        pinNumberStepper.accessibilityIdentifier = "GPIOPinNumberStepper"
        pollingStepper.accessibilityIdentifier = "GPIOPinPollingStepper"
        pinType.accessibilityIdentifier = "GPIOPinTypeControl"
        
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
            return 2
        case 1:
            if pin.type == .output {
                return 1
            }
            return 2
        default:
            return 2
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
    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
 
    // MARK: UITextFieldDelegate
    
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case pinNameTextField:
            dismissKeyboard()
        default:
            return true
        }
        return true
    }
    
    // MARK: Actions
    @IBAction func pinTypeHasChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            // Input
            pollingLabel.isEnabled = true
            pollingTextField.isEnabled = true
            pollingStepper.isEnabled = true
            pin.type = .input
        } else {
            // Output
            pollingLabel.isEnabled = false
            pollingTextField.isEnabled = false
            pollingStepper.isEnabled = false
            pin.type = .output
        }
        tableView.reloadData()
    }

    @IBAction func pinNumberStepperHasChanged(_ sender: UIStepper) {
        var pinNumber = UInt(pinNumberStepper.value)
        pinNumber = availablePins[Int(pinNumberStepper.value)]
        pinNumberTextField.text = "\(pinNumber)"
        pin.number = pinNumber
        let regex = try! NSRegularExpression(pattern: "^GPIO-([2-9]|1\\d|2[0-7])$", options: [])
        let match = regex.matches(in: pin.name, options: [], range: NSRange(location: 0, length: pin.name.characters.count))
        if match.count > 0 {
            pin.name = "GPIO-\(pinNumber)"
            pinNameTextField.text = pin.name
            delegate?.reloadData()
        }
    }
    
    @IBAction func pollingStepperHasChanged(_ sender: UIStepper) {
        pollingTextField.text = "\(UInt(pollingStepper.value))"
        pin.polling = UInt(pollingStepper.value)
    }
}
