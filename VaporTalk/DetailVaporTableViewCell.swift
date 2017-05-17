//
//  DetailVaporTableViewCell.swift
//  VaporTalk
//
//  Created by 이상윤 on 2017. 4. 20..
//  Copyright © 2017년 이상윤. All rights reserved.
//

import UIKit

class DetailVaporTableViewCell: UITableViewCell {

    @IBOutlet weak var remainTimerLabel: UILabel!
    @IBOutlet weak var vaporTimestampLabel: UILabel!
    @IBOutlet weak var logLabel: UILabel!
    @IBOutlet weak var remainTimerTitleLabel: UILabel!
    @IBOutlet weak var contentImgView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
