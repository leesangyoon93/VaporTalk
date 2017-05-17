//
//  FriendTableViewCell.swift
//  VaporTalk
//
//  Created by 이상윤 on 2017. 4. 1..
//  Copyright © 2017년 이상윤. All rights reserved.
//

import UIKit

class FriendTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImgView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        profileImgView.layer.cornerRadius = self.profileImgView.frame.width / 2.0
        profileImgView.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
