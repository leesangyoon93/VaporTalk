//
//  EventModel.swift
//  VaporTalk
//
//  Created by 이상윤 on 2017. 5. 18..
//  Copyright © 2017년 이상윤. All rights reserved.
//

import Foundation
import Firebase

class EventModel: NSObject {
    var events = [Event]()
    var sendCompleteDelegate: SendCompleteDelegate?
    var eventChangeDelegate: EventChangeDelegate?
    
    func sendEvent(event: Event, eventImage: UIImage? = #imageLiteral(resourceName: "NoImageAvailable")) {
        let ref = FIRDatabase.database().reference()
        let storage = FIRStorage.storage().reference().child("event").child("\(event.hostUID!)/\(event.imageUrl!)")
        let metadata = FIRStorageMetadata()
        metadata.contentType = "image/jpeg"
        
        if let uploadData = UIImageJPEGRepresentation(eventImage!, 0.5) {
            storage.put(uploadData, metadata: metadata, completion: { (metadata, error) in
                if error != nil {
                    return
                }
                
                let eventRef = ref.child("eventData").childByAutoId()
                let eventValues = ["hostUID": event.hostUID!, "hostName": event.hostName!, "title": event.title!, "content": event.content!, "imageUrl": (metadata?.name!)!, "timer": event.timer!, "latitude": event.latitude!, "longtitude": event.longtitude!, "location": event.location!, "timestamp": event.timestamp!] as [String : Any]
                eventRef.updateChildValues(eventValues, withCompletionBlock: { (error, ref) in
                    self.sendCompleteDelegate?.didComplete()
                })
            })
        }
    }

    func fetchEvents() {
        let ref = FIRDatabase.database().reference()
        let eventRef = ref.child("events").child(UserDefaults.standard.object(forKey: "uid") as! String)
        eventRef.observe(.value, with: { (snapshot) in
            self.events.removeAll()
            if let dic = snapshot.value as? [String: AnyObject] {
                for (_, value) in dic {
                    let event = Event(hostUID: value["hostUID"] as! String, hostName: value["hostName"] as! String, title: value["title"] as! String, content: value["content"] as! String, imageUrl: value["imageUrl"] as! String, timer: value["timer"] as! Double, latitude: value["latitude"] as! Double, longtitude: value["longtitude"] as! Double, location: value["location"] as! String, timestamp: value["timestamp"] as! String)
                    self.events.append(event)
                }
                self.eventChangeDelegate?.didChange()
            }
        })
    }
}
