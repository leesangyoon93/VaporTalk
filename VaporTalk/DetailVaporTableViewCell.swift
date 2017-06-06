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
    @IBOutlet weak var contentImgView: UIImageView!
    @IBOutlet weak var timestampImgView: UIImageView!
    @IBOutlet weak var timerImgView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentImgView.layer.cornerRadius = 2.0
        contentImgView.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
