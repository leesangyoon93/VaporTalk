//
//  Anonymous.swift
//  VaporTalk
//
//  Created by 이상윤 on 2017. 4. 13..
//  Copyright © 2017년 이상윤. All rights reserved.
//

class Anonymous: NSObject {
    private let UID: String?
    private let name: String?
    private let email: String?
    private let profileImage: String?
    private let tel: String?
    private var isFriend: Bool?
    
    override init() {
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
    
    public func getUID() -> String {
        return self.UID!
    }
    public func getName() -> String {
        return self.name!
    }
    public func getEmail() -> String {
        return self.email!
    }
    public func getProfileImage() -> String {
        return self.profileImage!
    }
    public func getTel() -> String {
        return self.tel!
    }
    public func getIsFriend() -> Bool {
        return self.isFriend!
    }
    
    public func setIsFriend(_ isFriend: Bool) {
        self.isFriend = isFriend
    }
}
