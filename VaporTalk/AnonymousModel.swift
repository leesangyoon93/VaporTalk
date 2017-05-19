//
//  AnonymousModel.swift
//  VaporTalk
//
//  Created by 이상윤 on 2017. 5. 19..
//  Copyright © 2017년 이상윤. All rights reserved.
//

import Contacts
import Firebase

class AnonymousModel: NSObject {
    var anonymousList = [Anonymous]()
    var contacts = [Anonymous]()
    var anonymousUpdateDelegate: AnonymousUpdateDelegate?
    
    func fetchAnonymous(_ cnContacts: [CNContact]) {
        let ref = FIRDatabase.database().reference()
        ref.child("users").observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
            if let dic = snapshot.value as? [String: AnyObject] {
                for (key, value) in dic {
                    var anonymous = Anonymous(UID: key, name: value["name"] as! String, email: value["email"] as! String,
                                              profileImage: value["profileImage"] as! String, tel: value["tel"] as! String, isFriend: false)
                    
                    for friend in UserModel().getFriends() {
                        if anonymous.UID! == friend.uid {
                            anonymous.setIsFriend(true)
                        }
                    }
                    
                    for contact in cnContacts {
                        if contact.phoneNumbers.count != 0 {
                            let tel = (contact.phoneNumbers[0].value).value(forKey: "digits") as? String
                            if value["tel"] as? String == tel! {
                                self.contacts.append(anonymous)
                            }
                        }
                    }
                    self.anonymousList.append(anonymous)
                }
                self.anonymousUpdateDelegate?.didUpdate()
            }
            
        })
    }
    
    func getAnonymousList() -> [Anonymous] {
        return anonymousList
    }
    
    func getContacts() -> [Anonymous] {
        return contacts
    }
}
