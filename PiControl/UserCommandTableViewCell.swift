//
//  UserCommandTableViewCell.swift
//  PiControl
//
//  Created by Julien Spronck on 13/02/2017.
//  Copyright © 2017 Julien Spronck. All rights reserved.
//

import UIKit

class UserCommandTableViewCell: UITableViewCell {
    
    // MARK: Properties
    
    @IBOutlet weak var buttonNameTextField: UITextField!
    @IBOutlet weak var commandStringTextField: UITextField!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
