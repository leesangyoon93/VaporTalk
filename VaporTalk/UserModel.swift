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
        friend.uid = anonymous.UID!
        friend.name = anonymous.name!
        friend.email = anonymous.email!
        friend.profileImage = anonymous.profileImage!
        friend.tel = anonymous.tel!
        delegate.saveContext()
        
        let ref = FIRDatabase.database().reference()
        let friendReference = ref.child("friends").child(UserDefaults.standard.object(forKey: "uid") as! String).child(anonymous.UID!)
        let values = ["name": anonymous.name!, "profileImage": anonymous.profileImage!, "email": anonymous.email!, "tel": anonymous.tel!]
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
        
        sortFriends()

        return self.friends
    }
    
    private func sortFriends() {
        friends.sort { (object1, object2) -> Bool in
            if object1.name! == object2.name! {
                return object1.tel! < object2.tel!
            }
            else {
                return object1.name! < object2.name!
            }
        }
    }
}
