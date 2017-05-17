//
//  FriendChoiceTableViewCell.swift
//  VaporTalk
//
//  Created by 이상윤 on 2017. 4. 17..
//  Copyright © 2017년 이상윤. All rights reserved.
//

import UIKit

class FriendChoiceTableViewCell: UITableViewCell {

    @IBOutlet weak var friendProfileImgView: UIImageView!
    @IBOutlet weak var friendNameLabel: UILabel!
    @IBOutlet weak var checkButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        friendProfileImgView.layer.cornerRadius = friendProfileImgView.frame.width / 2.0
        friendProfileImgView.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
