//
//  DashboardAnyCommandTableViewCell.swift
//  PiControl
//
//  Created by Julien Spronck on 15/02/2017.
//  Copyright © 2017 Julien Spronck. All rights reserved.
//

import UIKit

class DashboardAnyCommandTableViewCell: UITableViewCell {

    // MARK: Properties
    
    @IBOutlet weak var commandTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func sendCommand(_ sender: UIButton) {
        let command = commandTextField.text ?? ""
        if !command.isEmpty {
            print("Sending \(command)")
            commandTextField.text = ""
        }
    }
}
