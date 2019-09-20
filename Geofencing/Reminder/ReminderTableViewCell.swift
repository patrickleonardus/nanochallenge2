//
//  ReminderTableViewCell.swift
//  Geofencing
//
//  Created by Patrick Leonardus on 19/09/19.
//  Copyright © 2019 Patrick Leonardus. All rights reserved.
//

import UIKit

class ReminderTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubtitle: UITextView!
    @IBOutlet weak var lblClock: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
