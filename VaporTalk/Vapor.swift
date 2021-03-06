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
    
    func getActiveVaporTime() -> String {
        return getTimeToString(getRemainTime())
    }
    
    func getNotActiveVaporTime() -> String {
        return getTimeToString(getDiffTime())
    }
    
    private func getTimeToString(_ time: Int) -> String {
        let (h,m,_) = secondsToHoursMinutesSeconds(seconds: time)
        var timeString = ""
        if h > 0 {
            timeString = "\(h)시간 "
        }
        timeString = timeString + "\(m)분"
        return timeString

    }
    
    private func getDiffTime() -> Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        let vaporTimestamp = dateFormatter.date(from: self.timestamp!)
        let diffTime = Int(Date().timeIntervalSince(vaporTimestamp!))
        return diffTime
    }
    
    public func getRemainTime() -> Int {
        return Int(self.timer!) - getDiffTime()
    }
    
    private func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }

}
