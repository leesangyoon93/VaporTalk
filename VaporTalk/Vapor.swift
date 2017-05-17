//
//  Vapor.swift
//  VaporTalk
//
//  Created by 이상윤 on 2017. 4. 13..
//  Copyright © 2017년 이상윤. All rights reserved.
//
import Firebase

final class Vapor: NSObject {
    private let contents: String?
    private let timer: Double?
    private let from: String?
    private let target: String?
    private let timestamp: String?
    private let isActive: Bool?
    private let key: String?
    
    init( _ from: String, _ target: String, _ contents: String, _ timer: Double,  _ isActive: Bool, _ timestamp: String, _ key: String) {
        self.contents = contents
        self.timer = timer
        self.from = from
        self.timestamp = timestamp
        self.target = target
        self.key = key
        self.isActive = isActive
    }
    
    func sendVapor() -> Bool {
        let ref = FIRDatabase.database().reference()
        
        let lastVaporReference = ref.child("lastMessages").child(self.target!)
        lastVaporReference.setValue(["from": self.from!])
        
        let vaporReference = ref.child("messages").child(self.target!).child(self.from!).childByAutoId()
        let vaporValues = ["from": self.from!, "isActive": self.isActive!,
                           "contents": self.contents!, "timer": self.timer!, "timestamp": self.timestamp!] as [String : Any]
        vaporReference.updateChildValues(vaporValues)
        return true
    }
    
    func getFrom() -> String {
        return self.from!
    }
    
    func getContents() -> String {
        return self.contents!
    }
    
    func getTimer() -> Double {
        return self.timer!
    }
    
    func getTimestamp() -> String {
        return self.timestamp!
    }
    
    func getIsActive() -> Bool {
        return self.isActive!
    }
    
    func getKey() -> String {
        return self.key!
    }
}
