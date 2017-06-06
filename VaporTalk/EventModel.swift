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
        
        let uploadImage = eventImage ?? #imageLiteral(resourceName: "NoImageAvailable")
        
        if let uploadData = UIImageJPEGRepresentation(uploadImage, 0.5) {
            storage.put(uploadData, metadata: metadata, completion: { (metadata, error) in
                let eventRef = ref.child("eventData").childByAutoId()
                let eventValues = ["hostUID": event.hostUID!, "hostName": event.hostName!, "title": event.title!, "content": event.content!, "imageUrl": (metadata?.name!)!, "timer": event.timer!, "latitude": event.latitude!, "longtitude": event.longtitude!, "location": event.location!, "timestamp": event.timestamp!, "distance": 1000] as [String : Any]
                eventRef.updateChildValues(eventValues, withCompletionBlock: { (error, ref) in
                    self.sendCompleteDelegate?.didComplete()
                })
            })
        }
    }

    func fetchEvents() {
        let ref = FIRDatabase.database().reference()
        let eventRef = ref.child("events").child(UserDefaults.standard.object(forKey: "uid") as! String)
        
        eventRef.observe(.value, with: { (eventSnapshot) in
            self.events.removeAll()
            
            if let dic = eventSnapshot.value as? [String: AnyObject] {
                for (key, _) in dic {
                    let eventDataRef = ref.child("eventData").child(key)
                    eventDataRef.observeSingleEvent(of: .value, with: { (eventDataSnapshot) in
                        if let value = eventDataSnapshot.value as? [String: AnyObject] {
                            let event = Event(hostUID: value["hostUID"] as! String, hostName: value["hostName"] as! String, title: value["title"] as! String, content: value["content"] as! String, imageUrl: value["imageUrl"] as! String, timer: value["timer"] as! Double, latitude: value["latitude"] as! Double, longtitude: value["longtitude"] as! Double, location: value["location"] as! String, timestamp: value["timestamp"] as! String, key: key)
                            self.events.append(event)
                        }
                        self.sortEvents()
                        self.eventChangeDelegate?.didChange(self.events)
                    })
                }
            }
            else {
                self.eventChangeDelegate?.didChange(self.events)
            }
        })
    }
    
    private func sortEvents() {
        events.sort { (object1, object2) -> Bool in
            return object1.getRemainTime() < object2.getRemainTime()
        }
    }
}
