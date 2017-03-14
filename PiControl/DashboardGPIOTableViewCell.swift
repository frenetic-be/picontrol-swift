//
//  DashboardGPIOTableViewCell.swift
//  PiControl
//
//  Created by Julien Spronck on 15/02/2017.
//  Copyright © 2017 Julien Spronck. All rights reserved.
//

import UIKit

protocol GPIODictionaryProtocol {
    func updateGPIODictionary(pinNumber: Int, value: Int)
}

class DashboardGPIOTableViewCell: UITableViewCell {

    var pinNumber: UInt = 2
    var socket: SocketIOManager?
    var delegate: GPIODictionaryProtocol?
    
    @IBOutlet weak var GPIOLabel: UILabel!
    @IBOutlet weak var GPIOSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func GPIOSwitchHasChanged(_ sender: UISwitch) {
        socket?.setGPIO(pin: Int(pinNumber), value: sender.isOn)
        delegate?.updateGPIODictionary(pinNumber: Int(pinNumber), value: sender.isOn ? 1 : 0)
    }
    

}
