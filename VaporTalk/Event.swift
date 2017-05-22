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
    let password: String?
    let key: String?
    
    init(hostUID: String, hostName: String, title: String, content: String, imageUrl: String, timer: Double, latitude: Double, longtitude: Double, location: String, timestamp: String, password: String = "1234", key: String = "") {
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
        self.password = password
        self.key = key
    }
    
    func getRemainTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        let eventTimestamp = dateFormatter.date(from: self.timestamp!)
        let diffTime = Int(Date().timeIntervalSince(eventTimestamp!))
        let remainTime = Int(self.timer!) - diffTime
        let (h,m,_) = secondsToHoursMinutesSeconds(seconds: remainTime)
        var timeString = ""
        if h > 0 {
            timeString = "\(h)시간 "
        }
        timeString = timeString + "\(m)분"
        return timeString
    }
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
}
