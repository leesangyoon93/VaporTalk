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
    var delegate: VaporChangeDelegate?
    
    func fetchVapors() {
        let ref = FIRDatabase.database().reference()
        let vaporRef = ref.child("messages").child(UserDefaults.standard.object(forKey: "uid") as! String)
        vaporRef.observe(.value, with: { (snapshot) in
            if let dic = snapshot.value as? [String: AnyObject] {
                for (from, value) in dic {
                    var vaporArr = [Vapor]()
                    for (key, data) in (value as! NSDictionary) {
                        let info = data as! [String: AnyObject]
                        let vapor = Vapor(from , UserDefaults.standard.object(forKey: "uid") as! String, info["contents"] as! String, info["timer"] as! Double, info["isActive"] as! Bool, info["timestamp"] as! String, key as! String)
                        vaporArr.append(vapor)
                    }
                    self.allVapors.updateValue(vaporArr, forKey: from)
                }
            }
            self.delegate?.onDataChange!()
        })
    }
    
    func fetchDetailVapors(_ uid: String) {
        let ref = FIRDatabase.database().reference()
        let vaporRef = ref.child("messages").child(UserDefaults.standard.object(forKey: "uid") as! String).child(uid)
        
        vaporRef.observe(.value, with: { (snapshot) in
            self.detailVapors = [Vapor]()
            
            if let dic = snapshot.value as? [String: AnyObject] {
                for (key, value) in dic {
                    let vapor = Vapor(uid, UserDefaults.standard.object(forKey: "uid") as! String, value["contents"] as! String, value["timer"] as! Double, value["isActive"] as! Bool, value["timestamp"] as! String, key)
                    self.detailVapors.append(vapor)
                }
            }
            self.delegate?.onVaporUpdated!()
        })
    }
    
    func removeUserVapor(from: String) {
        // 스토리지 폴더삭제 안됨..?
        allVapors.removeValue(forKey: from)
        
        let storage = FIRStorage.storage().reference()
        let storageRef = storage.child("contents/\(UserDefaults.standard.object(forKey: "uid") as! String)/\(from)")
        
        storageRef.delete { (error) in
            if error != nil {
                return
            }
        }
        let ref = FIRDatabase.database().reference()
        let vaporRef = ref.child("messages").child(UserDefaults.standard.object(forKey: "uid") as! String).child(from)
        vaporRef.removeValue()
        
        
        //self.delegate?.onDataChange!()
        // 베이퍼 한개 지울때 쓰자
        //vapors[vapor.getFrom()]?.remove(at: (vapors[vapor.getFrom()]?.index(of: vapor))!)
    }
    
    func getAllVapors() -> [String:[Vapor]] {
        return allVapors
    }
    
    func getDetailVapors(_ uid: String) -> [Vapor] {
        return detailVapors
    }
}
