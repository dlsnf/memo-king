//
//  MainCell.swift
//  MemoKing
//
//  Created by Nu-Ri Lee on 2017. 4. 12..
//  Copyright © 2017년 nuri lee. All rights reserved.
//

import UIKit

class MainCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var subTitleLabel: UILabel!
    
    @IBOutlet weak var additionalText: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
