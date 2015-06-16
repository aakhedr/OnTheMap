//
//  CellDetailViewController.swift
//  OnTheMap
//
//  Created by Ahmed Khedr on 6/14/15.
//  Copyright (c) 2015 Ahmed Khedr. All rights reserved.
//

import UIKit

class CellDetailViewController: UITableViewCell {

    @IBOutlet weak var studentFullName: UILabel!
    @IBOutlet weak var studentURL: UILabel!
    @IBOutlet weak var studentLocationString: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
