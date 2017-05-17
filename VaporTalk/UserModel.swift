//
//  User.swift
//  VaporTalk
//
//  Created by 이상윤 on 2017. 4. 2..
//  Copyright © 2017년 이상윤. All rights reserved.
//

import FirebaseAuth
import FirebaseDatabase
import CoreData

final class UserModel: NSObject {
    private var friends = [Friend]()
    
    public func addFriend(_ anonymous: Anonymous) {
        let delegate = (UIApplication.shared.delegate as! AppDelegate)
        let context = delegate.persistentContainer.viewContext

        let friend = Friend(context: context)
        friend.uid = anonymous.getUID()
        friend.name = anonymous.getName()
        friend.email = anonymous.getEmail()
        friend.profileImage = anonymous.getProfileImage()
        friend.tel = anonymous.getTel()
        delegate.saveContext()
        
        let ref = FIRDatabase.database().reference()
        let friendReference = ref.child("friends").child(UserDefaults.standard.object(forKey: "uid") as! String).child(anonymous.getUID())
        let values = ["name": anonymous.getName(), "profileImage": anonymous.getProfileImage(), "email": anonymous.getEmail(), "tel": anonymous.getTel()]
        friendReference.updateChildValues(values)
    }
    
    public func removeFriend(_ friend: Friend) {
        let ref = FIRDatabase.database().reference()
        let friendReference = ref.child("friends").child(UserDefaults.standard.object(forKey: "uid") as! String).child(friend.uid!)
        friendReference.removeValue()
        
        let delegate = (UIApplication.shared.delegate as! AppDelegate)
        let context = delegate.persistentContainer.viewContext
        
        context.delete(friend)
        delegate.saveContext()
    }
    
    public func getFriends() -> [Friend] {
        let delegate = (UIApplication.shared.delegate as! AppDelegate)
        let context = delegate.persistentContainer.viewContext
        do {
            self.friends = try context.fetch(Friend.fetchRequest())
        } catch {
            print("error")
        }
        
        friends.sort { (object1, object2) -> Bool in
            if object1.name! == object2.name! {
                return object1.tel! < object2.tel!
            }
            else {
                return object1.name! < object2.name!
            }
        }

        return self.friends
    }
}
