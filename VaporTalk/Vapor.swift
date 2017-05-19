//
//  Vapor.swift
//  VaporTalk
//
//  Created by 이상윤 on 2017. 4. 13..
//  Copyright © 2017년 이상윤. All rights reserved.
//
import Firebase

struct Vapor {
    var contents: String?
    var timer: Double?
    var from: String?
    var target: String?
    var timestamp: String?
    var isActive: Bool?
    
    init(_ from: String, _ target: String, _ contents: String, _ timer: Double,  _ isActive: Bool, _ timestamp: String) {
        self.contents = contents
        self.timer = timer
        self.from = from
        self.timestamp = timestamp
        self.target = target
        self.isActive = isActive
    }
    
    mutating func setContent(content: String) {
        contents = content
    }
}
