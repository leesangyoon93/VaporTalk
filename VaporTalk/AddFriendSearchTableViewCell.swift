//
//  AddFriendSearchTableViewCell.swift
//  VaporTalk
//
//  Created by 이상윤 on 2017. 4. 6..
//  Copyright © 2017년 이상윤. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class AddFriendSearchTableViewCell: UITableViewCell {

    var anonymous: Anonymous?
    @IBOutlet weak var addFriendButton: UIButton!
    @IBOutlet weak var friendProfileImageView: UIImageView!
    @IBOutlet weak var friendProfileNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
}
