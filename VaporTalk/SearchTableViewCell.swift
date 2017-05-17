//
//  SearchTableViewCell.swift
//  VaporTalk
//
//  Created by 이상윤 on 2017. 4. 14..
//  Copyright © 2017년 이상윤. All rights reserved.
//

import UIKit

class SearchTableViewCell: UITableViewCell {

    @IBOutlet weak var searchFriendProfileImage: UIImageView!
    @IBOutlet weak var searchFriendNameLabel: UILabel!
    @IBOutlet weak var searchFriendEmailLabel: UILabel!
    @IBOutlet weak var addFriendButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
