//
//  Anonymous.swift
//  VaporTalk
//
//  Created by 이상윤 on 2017. 4. 13..
//  Copyright © 2017년 이상윤. All rights reserved.
//
import UIKit

struct Anonymous {
    let UID: String?
    let name: String?
    let email: String?
    let tel: String?
    var isFriend: Bool?
    var profileImage: UIImage?
    
    init() {
        self.UID = ""
        self.name = ""
        self.email = ""
        self.tel = ""
        self.isFriend = false
        self.profileImage = nil
    }
    
    init(UID: String, name: String, email: String, tel: String, isFriend: Bool, profileImage: UIImage? = #imageLiteral(resourceName: "NoImageAvailable")) {
        self.UID = UID
        self.name = name;
        self.email = email;
        self.tel = tel
        self.isFriend = isFriend
        self.profileImage = profileImage
    }
    
    mutating func setIsFriend(_ isFriend: Bool) {
        self.isFriend = isFriend
    }
    
    mutating func setProfileImage(_ profileImage: UIImage) {
        self.profileImage = profileImage
    }
}
