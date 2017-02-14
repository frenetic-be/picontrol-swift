//
//  MasterSwitchTableViewCell.swift
//  PiControl
//
//  Created by Julien Spronck on 13/02/2017.
//  Copyright © 2017 Julien Spronck. All rights reserved.
//

import UIKit

class MasterSwitchTableViewCell: UITableViewCell {
    
    // MARK: Properties    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var `switch`: UISwitch!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
