//
//  DashboardGPIOTableViewCell.swift
//  PiControl
//
//  Created by Julien Spronck on 15/02/2017.
//  Copyright © 2017 Julien Spronck. All rights reserved.
//

import UIKit

class DashboardGPIOTableViewCell: UITableViewCell {

    var pinNumber: UInt = 2
    
    @IBOutlet weak var GPIOLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func GPIOSwitchHasChanged(_ sender: UISwitch) {
        print("\(pinNumber): \(sender.isOn)")
    }
    

}
