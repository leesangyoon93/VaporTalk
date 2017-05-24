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
        let storage = FIRStorage.storage()
        var count = 0
        
        ref.child("users").observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
            if let dic = snapshot.value as? [String: AnyObject] {
                for (key, value) in dic {
                    let profileImageReference = storage.reference().child("profile/\(key)")
                    
                    profileImageReference.data(withMaxSize: 1 * 1024 * 1024) { (data, error) -> Void in
                        var anonymous = Anonymous(UID: key, name: value["name"] as! String, email: value["email"] as! String,
                                                  tel: value["tel"] as! String, isFriend: false, profileImage: UIImage(data: data!))
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
                        
                        count = count + 1
                        if count == dic.count {
                            self.sortContacts()
                            self.anonymousUpdateDelegate?.didUpdate(self.anonymousList, self.contacts)
                        }
                    }
                }
            }
        })
    }
    
    private func sortContacts() {
        self.contacts.sort { (object1, object2) -> Bool in
            if object1.name! == object2.name! {
                return object1.tel! < object2.tel!
            }
            else {
                return object1.name! < object2.name!
            }
        }
        self.anonymousList.sort { (object1, object2) -> Bool in
            if object1.name! == object2.name! {
                return object1.tel! < object2.tel!
            }
            else {
                return object1.name! < object2.name!
            }
        }
    }
}
