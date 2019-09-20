//
//  HomeReflectionTableViewCell.swift
//  Geofencing
//
//  Created by Patrick Leonardus on 19/09/19.
//  Copyright © 2019 Patrick Leonardus. All rights reserved.
//

import UIKit

class HomeReflectionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var inputDate: UILabel!
    @IBOutlet weak var inputTitle: UILabel!
    @IBOutlet weak var inputDesc: UITextView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
