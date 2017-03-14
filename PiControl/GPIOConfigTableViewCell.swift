//
//  GPIOConfigTableViewCell.swift
//  PiControl
//
//  Created by Julien Spronck on 07/03/2017.
//  Copyright © 2017 Julien Spronck. All rights reserved.
//

import UIKit

class GPIOConfigTableViewCell: UITableViewCell {

    @IBOutlet weak var configButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func addSubview(_ view: UIView) {
        if view.frame.height*UIScreen.main.scale == 1 {
            return
        }
        
        super.addSubview(view)
    }
    
}
