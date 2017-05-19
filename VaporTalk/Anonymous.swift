//
//  Anonymous.swift
//  VaporTalk
//
//  Created by 이상윤 on 2017. 4. 13..
//  Copyright © 2017년 이상윤. All rights reserved.
//

struct Anonymous {
    var UID: String?
    var name: String?
    var email: String?
    var profileImage: String?
    var tel: String?
    var isFriend: Bool?
    
    init() {
        self.UID = ""
        self.name = ""
        self.email = ""
        self.profileImage = ""
        self.tel = ""
        self.isFriend = false
    }
    
    init(UID: String, name: String, email: String, profileImage: String, tel: String, isFriend: Bool) {
        self.UID = UID
        self.name = name;
        self.email = email;
        self.profileImage = profileImage
        self.tel = tel
        self.isFriend = isFriend
    }
    
    mutating func setIsFriend(_ isFriend: Bool) {
        self.isFriend = isFriend
    }
}
