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
    var vaporListChangeDelegate: VaporListChangeDelegate?
    var detailVaporChangeDelegate: DetailVaporChangeDelegate?
    var sendCompleteDelegate: SendCompleteDelegate?
    
    let ref = FIRDatabase.database().reference()
    
    func sendVapor(vapor: Vapor, vaporImage: UIImage) {
        let storage = FIRStorage.storage().reference().child("vapor").child("\(vapor.target!)/\(UserDefaults.standard.object(forKey: "uid") as! String)/\(vapor.contents!)")
        let metadata = FIRStorageMetadata()
        metadata.contentType = "image/jpeg"
        
        if let uploadData = UIImageJPEGRepresentation(vaporImage, 0.5) {
            storage.put(uploadData, metadata: metadata, completion: { (metadata, error) in
                let lastVaporRef = self.ref.child("lastMessages").child(UserDefaults.standard.object(forKey: "uid") as! String)
                lastVaporRef.setValue(["from": UserDefaults.standard.object(forKey: "uid") as! String])
                
                let vaporRef = self.ref.child("messages").child(vapor.target!).child(vapor.from!).childByAutoId()
                let vaporValues = ["from": vapor.from!, "isActive": vapor.isActive!,
                                   "contents": metadata?.name! ?? "", "timer": vapor.timer!, "timestamp": vapor.timestamp!] as [String : Any]
                vaporRef.updateChildValues(vaporValues) { (error, ref) in
                    self.sendCompleteDelegate?.didComplete()
                }
            })
        }
    }
    
    func fetchVapors() {
        let vaporRef = ref.child("messages").child(UserDefaults.standard.object(forKey: "uid") as! String)
        vaporRef.observe(.value, with: { (snapshot) in
            self.allVapors.removeAll()
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
                self.vaporListChangeDelegate?.didChange(self.allVapors)
            }
            else {
                self.vaporListChangeDelegate?.didChange(self.allVapors)
            }
        })
    }
    
    func fetchDetailVapors(_ uid: String) {
        let vaporRef = ref.child("messages").child(UserDefaults.standard.object(forKey: "uid") as! String).child(uid)
        
        vaporRef.observe(.value, with: { (snapshot) in
            self.detailVapors.removeAll()
            
            if let dic = snapshot.value as? [String: AnyObject] {
                for (_, value) in dic {
                    let vapor = Vapor(uid, UserDefaults.standard.object(forKey: "uid") as! String, value["contents"] as! String, value["timer"] as! Double, value["isActive"] as! Bool, value["timestamp"] as! String)
                    self.detailVapors.append(vapor)
                }
                self.detailVaporChangeDelegate?.didChange(self.detailVapors)
            }
            else {
                self.detailVaporChangeDelegate?.didChange(self.detailVapors)
            }
        })
    }
    
    func removeUserVapor(_ uid: String) {
        allVapors.removeValue(forKey: uid)
        
        let storage = FIRStorage.storage().reference()
        let storageRef = storage.child("vapor/\(UserDefaults.standard.object(forKey: "uid") as! String)/\(uid)")
        
        storageRef.delete { (error) in
            if error != nil {
                return
            }
        }
        
        let vaporRef = ref.child("messages").child(UserDefaults.standard.object(forKey: "uid") as! String).child(uid)
        vaporRef.removeValue()
        
        self.vaporListChangeDelegate?.didChange(self.allVapors)

        //vapors[vapor.getFrom()]?.remove(at: (vapors[vapor.getFrom()]?.index(of: vapor))!)
    }
}
