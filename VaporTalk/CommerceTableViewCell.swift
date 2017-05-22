//
//  CommerceTableViewCell.swift
//  VaporTalk
//
//  Created by 이상윤 on 2017. 5. 21..
//  Copyright © 2017년 이상윤. All rights reserved.
//

import UIKit

class CommerceTableViewCell: UITableViewCell {

    @IBOutlet weak var commerceTitleLabel: UILabel!
    @IBOutlet weak var commerceLocationLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
