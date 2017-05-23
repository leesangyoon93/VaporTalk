//
//  CommerceModel.swift
//  VaporTalk
//
//  Created by 이상윤 on 2017. 5. 21..
//  Copyright © 2017년 이상윤. All rights reserved.
//

import Foundation
import Firebase

class CommerceModel: NSObject {
    var commerces = [Event]()
    var sendCompleteDelegate: SendCompleteDelegate?
    var commerceChangeDelegate: CommerceChangeDelegate?
    
    func sendCommerce(commerce: Event, commerceData: CommerceAnalysis, commerceImage: UIImage? = #imageLiteral(resourceName: "NoImageAvailable")) {
        let ref = FIRDatabase.database().reference()
        
        let storage = FIRStorage.storage().reference().child("commerce").child("\(commerce.hostUID!)/\(commerce.imageUrl!)")
        let metadata = FIRStorageMetadata()
        metadata.contentType = "image/jpeg"
        
        let uploadImage = commerceImage ?? #imageLiteral(resourceName: "NoImageAvailable")
        
        if let uploadData = UIImageJPEGRepresentation(uploadImage, 0.5) {
            storage.put(uploadData, metadata: metadata, completion: { (metadata, error) in
                let commerceRef = ref.child("commerceData").childByAutoId()
                let commerceValues = ["hostUID": commerce.hostUID!, "hostName": commerce.hostName!, "title": commerce.title!, "content": commerce.content!, "imageUrl": (metadata?.name!)!, "timer": commerce.timer!, "latitude": commerce.latitude!, "longtitude": commerce.longtitude!, "location": commerce.location!, "timestamp": commerce.timestamp!, "password": commerce.password!, "distance": 1000] as [String : Any]
                commerceRef.updateChildValues(commerceValues, withCompletionBlock: { (error, ref) in
                    let commerceDataRef = ref.child("commerceAnalysis")
                    let commerceValues = ["type": commerceData.type!, "keyword": commerceData.keyword!]
                    commerceDataRef.updateChildValues(commerceValues, withCompletionBlock: { (error, ref) in
                        self.sendCompleteDelegate?.didComplete()
                    })
                })
            })
        }
    }
    
    func fetchCommerces() {
        let ref = FIRDatabase.database().reference()
        let commerceRef = ref.child("commerces").child(UserDefaults.standard.object(forKey: "uid") as! String)
        
        commerceRef.observe(.value, with: { (commerceSnapshot) in
            self.commerces.removeAll()
            
            if let dic = commerceSnapshot.value as? [String: AnyObject] {
                for (key, _) in dic {
                    let commerceDataRef = ref.child("commerceData").child(key)
                    commerceDataRef.observeSingleEvent(of: .value, with: { (commerceDataSnapshot) in
                        if let value = commerceDataSnapshot.value as? [String: AnyObject] {
                            let commerce = Event(hostUID: value["hostUID"] as! String, hostName: value["hostName"] as! String, title: value["title"] as! String, content: value["content"] as! String, imageUrl: value["imageUrl"] as! String, timer: value["timer"] as! Double, latitude: value["latitude"] as! Double, longtitude: value["longtitude"] as! Double, location: value["location"] as! String, timestamp: value["timestamp"] as! String, password: value["password"] as! String, key: key)
                            self.commerces.append(commerce)
                        }
                        self.sortCommerces()
                        self.commerceChangeDelegate?.didChange(self.commerces)
                    })
                }
            }
            else {
                self.commerceChangeDelegate?.didChange(self.commerces)
            }
        })
    }
    
    func checkCommerce(_ commerce: Event) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        
        let ref = FIRDatabase.database().reference()
        let commerceRef = ref.child("commerces").child(UserDefaults.standard.object(forKey: "uid") as! String).child(commerce.key!)
        
        let buyerRef = ref.child("buyers").child(commerce.hostUID!).child(commerce.key!).childByAutoId()
        let buyerValues = ["buyer": UserDefaults.standard.object(forKey: "uid") as! String, "timestamp": dateFormatter.string(from: Date())]
        buyerRef.updateChildValues(buyerValues) { (error, ref) in
            commerceRef.removeValue()
        }
    }

    func sortCommerces() {
        commerces.sort { (object1, object2) -> Bool in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
            let object1Timestamp = dateFormatter.date(from: object1.timestamp!)
            let object2Timestamp = dateFormatter.date(from: object2.timestamp!)
            let diffTime1 = Int(Date().timeIntervalSince(object1Timestamp!))
            let diffTime2 = Int(Date().timeIntervalSince(object2Timestamp!))
            let remainTime1 = "\(Int(object1.timer!) - diffTime1)"
            let remainTime2 = "\(Int(object2.timer!) - diffTime2)"
            return remainTime1 < remainTime2
        }
    }
}
