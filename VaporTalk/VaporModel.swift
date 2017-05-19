//
//  VaporModel.swift
//  VaporTalk
//
//  Created by 이상윤 on 2017. 4. 18..
//  Copyright © 2017년 이상윤. All rights reserved.
//

import Firebase

class VaporModel: NSObject {
    var allVapors = [String:[Vapor]]()
    var detailVapors = [Vapor]()
    var vaporChangeDelegate: VaporChangeDelegate?
    var sendCompleteDelegate: SendCompleteDelegate?
    
    func sendVapor(vapor: Vapor, vaporImage: UIImage) {
        let ref = FIRDatabase.database().reference()
        let storage = FIRStorage.storage().reference().child("vapor").child("\(vapor.target!)/\(UserDefaults.standard.object(forKey: "uid") as! String)/\(vapor.contents!)")
        let metadata = FIRStorageMetadata()
        metadata.contentType = "image/jpeg"
        
        if let uploadData = UIImageJPEGRepresentation(vaporImage, 0.5) {
            storage.put(uploadData, metadata: metadata, completion: { (metadata, error) in
                if error != nil {
                    return
                }
                let lastVaporReference = ref.child("lastMessages").child(vapor.target!)
                lastVaporReference.setValue(["from": vapor.from!])
                
                let vaporReference = ref.child("messages").child(vapor.target!).child(vapor.from!).childByAutoId()
                let vaporValues = ["from": vapor.from!, "isActive": vapor.isActive!,
                                   "contents": metadata?.name! ?? "", "timer": vapor.timer!, "timestamp": vapor.timestamp!] as [String : Any]
                vaporReference.updateChildValues(vaporValues) { (error, ref) in
                    self.sendCompleteDelegate?.didComplete()
                }
            })
        }
    }
    
    func fetchVapors() {
        let ref = FIRDatabase.database().reference()
        let vaporRef = ref.child("messages").child(UserDefaults.standard.object(forKey: "uid") as! String)
        vaporRef.observe(.value, with: { (snapshot) in
            if let dic = snapshot.value as? [String: AnyObject] {
                for (from, value) in dic {
                    var vaporArr = [Vapor]()
                    for (_, data) in (value as! NSDictionary) {
                        let info = data as! [String: AnyObject]
                        let vapor = Vapor(from , UserDefaults.standard.object(forKey: "uid") as! String, info["contents"] as! String, info["timer"] as! Double, info["isActive"] as! Bool, info["timestamp"] as! String)
                        vaporArr.append(vapor)
                    }
                    self.allVapors.updateValue(vaporArr, forKey: from)
                }
            }
            self.vaporChangeDelegate?.didChange!()
        })
    }
    
    func fetchDetailVapors(_ uid: String) {
        let ref = FIRDatabase.database().reference()
        let vaporRef = ref.child("messages").child(UserDefaults.standard.object(forKey: "uid") as! String).child(uid)
        
        vaporRef.observe(.value, with: { (snapshot) in
            self.detailVapors = [Vapor]()
            
            if let dic = snapshot.value as? [String: AnyObject] {
                for (_, value) in dic {
                    let vapor = Vapor(uid, UserDefaults.standard.object(forKey: "uid") as! String, value["contents"] as! String, value["timer"] as! Double, value["isActive"] as! Bool, value["timestamp"] as! String)
                    self.detailVapors.append(vapor)
                }
            }
            self.vaporChangeDelegate?.didUpdated!()
        })
    }
    
    func removeUserVapor(from: String) {
        allVapors.removeValue(forKey: from)
        
        let storage = FIRStorage.storage().reference()
        let storageRef = storage.child("vapor/\(UserDefaults.standard.object(forKey: "uid") as! String)/\(from)")
        
        storageRef.delete { (error) in
            if error != nil {
                return
            }
        }
        let ref = FIRDatabase.database().reference()
        let vaporRef = ref.child("messages").child(UserDefaults.standard.object(forKey: "uid") as! String).child(from)
        vaporRef.removeValue()
        
        
        //self.delegate?.onDataChange!()
        //vapors[vapor.getFrom()]?.remove(at: (vapors[vapor.getFrom()]?.index(of: vapor))!)
    }
    
    func getAllVapors() -> [String:[Vapor]] {
        return allVapors
    }
    
    func getDetailVapors(_ uid: String) -> [Vapor] {
        return detailVapors
    }
}
