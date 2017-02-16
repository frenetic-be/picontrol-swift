//
//  DashboardCommandTableViewCell.swift
//  PiControl
//
//  Created by Julien Spronck on 15/02/2017.
//  Copyright © 2017 Julien Spronck. All rights reserved.
//

import UIKit

class DashboardCommandTableViewCell: UITableViewCell {

    // MARK: Properties
    
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var centralButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    
    var leftCommand = ""
    var centralCommand = ""
    var rightCommand = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        leftButton.layer.borderWidth = 1
        centralButton.layer.borderWidth = 1
        rightButton.layer.borderWidth = 1
        leftButton.layer.cornerRadius = 5
        centralButton.layer.cornerRadius = 5
        rightButton.layer.cornerRadius = 5
        let textColor = leftButton.titleColor(for: .normal) ?? UIColor.white
        leftButton.layer.borderColor = textColor.cgColor
        centralButton.layer.borderColor = textColor.cgColor
        rightButton.layer.borderColor = textColor.cgColor
        self.layer.backgroundColor = UIColor.clear.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: Actions
    
    @IBAction func leftButtonPressed(_ sender: UIButton) {
        print("Sending \(leftCommand)")
    }
    
    @IBAction func centralButtonPressed(_ sender: UIButton) {
        print("Sending \(centralCommand)")
    }
    
    @IBAction func rightButtonPressed(_ sender: UIButton) {
        print("Sending \(rightCommand)")
    }
    
    // MARK: Private methods
    func setButtons(commands: [PiCommand]){
        switch commands.count {
        case 0:
            return
        case 1:
            leftButton.isHidden = true
            rightButton.isHidden = true
            centralButton.isHidden = false
            centralButton.setTitle(commands[0].buttonName, for: .normal)
            centralCommand = commands[0].command
        case 2:
            leftButton.isHidden = false
            rightButton.isHidden = false
            centralButton.isHidden = true
            leftButton.setTitle(commands[0].buttonName, for: .normal)
            leftCommand = commands[0].command
            rightButton.setTitle(commands[1].buttonName, for: .normal)
            rightCommand = commands[1].command
        case 3:
            leftButton.isHidden = false
            rightButton.isHidden = false
            centralButton.isHidden = false
            leftButton.setTitle(commands[0].buttonName, for: .normal)
            leftCommand = commands[0].command
            centralButton.setTitle(commands[1].buttonName, for: .normal)
            centralCommand = commands[1].command
            rightButton.setTitle(commands[2].buttonName, for: .normal)
            rightCommand = commands[2].command
        default:
            return
        }

    }

}
