//
//  Event.swift
//  VaporTalk
//
//  Created by 이상윤 on 2017. 5. 18..
//  Copyright © 2017년 이상윤. All rights reserved.
//

import Foundation

struct Event {
    let hostUID: String?
    let hostName: String?
    let title: String?
    let content: String?
    let imageUrl: String?
    let timer: Double?
    let latitude: Double?
    let longtitude: Double?
    let location: String?
    let timestamp: String?
    
    init(hostUID: String, hostName: String, title: String, content: String, imageUrl: String, timer: Double, latitude: Double, longtitude: Double, location: String, timestamp: String) {
        self.hostUID = hostUID
        self.hostName = hostName
        self.title = title
        self.content = content
        self.imageUrl = imageUrl
        self.timer = timer
        self.latitude = latitude
        self.longtitude = longtitude
        self.location = location
        self.timestamp = timestamp
    }
}
