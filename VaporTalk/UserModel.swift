//
//  User.swift
//  VaporTalk
//
//  Created by 이상윤 on 2017. 4. 2..
//  Copyright © 2017년 이상윤. All rights reserved.
//

import Firebase
import CoreData

class UserModel: NSObject {
    var friends = [Friend]()
    var uploadCompleteDelegate: UploadCompleteDelegate?
    var updateFriendCompleteDelegate: UpdateFriendCompleteDelegate?
    var registerSuccessDelegate: RegisterSuccessDelegate?
    
    private var userData: [String: String]?
    private var profileData: Data?
    
    public func register(_ userData: [String: String], _ profileData: Data) {
        self.userData = userData
        self.profileData = profileData
        
        setUserDefaults(userData)
        resetFriends()
        
        let ref = FIRDatabase.database().reference()
        let userReference = ref.child("users").child(userData["uid"]!)
        let values = ["name": userData["name"]!, "email": userData["email"]!, "tel": userData["tel"]!, "sex": userData["gender"]!, "birthday": userData["birthday"]!, "isLocationAgree": "true", "isPushAgree": "true"] as [String: Any]
        
        let lastVaporReference = ref.child("lastMessages").child(userData["uid"]!)
        let lastVaporValues = ["from": ""]
        lastVaporReference.setValue(lastVaporValues)
        
        userReference.updateChildValues(values, withCompletionBlock: { (error, ref) in
            if error != nil {
                print(error ?? "")
                return
            }
            self.registerSuccessDelegate?.didSuccess(userData, profileData)
            
        })
    }
    
    func resetFriends() {
        let delegate = (UIApplication.shared.delegate as! AppDelegate)
        let context = delegate.persistentContainer.viewContext
        
        var friends = [Friend]()
        do {
            friends = try context.fetch(Friend.fetchRequest())
            for friend in friends {
                context.delete(friend)
            }
            delegate.saveContext()
        } catch {
            print("error")
        }
    }
    
    private func setUserDefaults(_ userData: [String: String]) {
        let user = UserDefaults.standard
        user.set(userData["uid"]! , forKey: "uid")
        user.set(userData["name"]!, forKey: "name")
        user.set(userData["email"]!, forKey: "email")
        user.set(userData["tel"]!, forKey: "tel")
        user.set("true", forKey: "isLocationAgree")
        user.set("true", forKey: "isPushAgree")
        user.set(profileData!, forKey: "profileImage")
    }
    
    public func updateProfileImage(_ profileImage: UIImage, _ uid: String) {
        let storage = FIRStorage.storage().reference().child("profile").child(uid)
        let metadata = FIRStorageMetadata()
        metadata.contentType = "image/jpeg"
        let croppedImage = profileImage.cropTo(size: CGSize(width: 200, height: 200))
        if let uploadData = UIImageJPEGRepresentation(croppedImage, 0.1) {
            storage.put(uploadData, metadata: metadata, completion: { (metadata, error) in
                self.uploadCompleteDelegate?.didComplete(croppedImage)
            })
        }
    }
    
    public func addFriend(_ anonymous: Anonymous) {
        let delegate = (UIApplication.shared.delegate as! AppDelegate)
        let context = delegate.persistentContainer.viewContext

        let friend = Friend(context: context)
        friend.uid = anonymous.UID!
        friend.name = anonymous.name!
        friend.email = anonymous.email!
        friend.tel = anonymous.tel!
        friend.profileImage = anonymous.profileImage!
        delegate.saveContext()
        
        let ref = FIRDatabase.database().reference()
        let friendReference = ref.child("friends").child(UserDefaults.standard.object(forKey: "uid") as! String).child(anonymous.UID!)
        let values = ["name": anonymous.name!, "email": anonymous.email!, "tel": anonymous.tel!]
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
            sortFriends()
        } catch {
            print("error")
        }
        return self.friends
    }
    
    func setFriendsProfileImage() {
        let storage = FIRStorage.storage()
        let delegate = (UIApplication.shared.delegate as! AppDelegate)
        let context = delegate.persistentContainer.viewContext
        var count = 0
        do {
            friends = try context.fetch(Friend.fetchRequest())
            if friends.count == 0 {
                self.updateFriendCompleteDelegate?.didUpdated(self.friends)
            }
            else {
                for friend in friends {
                    let profileImageReference = storage.reference().child("profile/\(friend.uid!)")
                    
                    profileImageReference.data(withMaxSize: 1 * 1024 * 1024) { (data, error) -> Void in
                        friend.setValue(UIImage(data: data!), forKey: "profileImage")
                        delegate.saveContext()
                        count = count + 1
                        if count == self.friends.count {
                            self.updateFriendCompleteDelegate?.didUpdated(self.friends)
                        }
                    }
                }
            }
        } catch {
            print("error")
        }
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

extension UIImage {
    func cropTo(size: CGSize) -> UIImage {
        guard let cgimage = self.cgImage else { return self }
        
        let contextImage: UIImage = UIImage(cgImage: cgimage)
        
        var cropWidth: CGFloat = size.width
        var cropHeight: CGFloat = size.height
        
        if (self.size.height < size.height || self.size.width < size.width){
            return self
        }
        
        let heightPercentage = self.size.height/size.height
        let widthPercentage = self.size.width/size.width
        
        if (heightPercentage < widthPercentage) {
            cropHeight = size.height*heightPercentage
            cropWidth = size.width*heightPercentage
        } else {
            cropHeight = size.height*widthPercentage
            cropWidth = size.width*widthPercentage
        }
        
        let posX: CGFloat = (self.size.width - cropWidth)/2
        let posY: CGFloat = (self.size.height - cropHeight)/2
        
        let rect: CGRect = CGRect(x: posX, y: posY, width: cropWidth, height: cropHeight)
        
        // Create bitmap image from context using the rect
        let imageRef: CGImage = contextImage.cgImage!.cropping(to: rect)!
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let cropped: UIImage = UIImage(cgImage: imageRef, scale: self.scale, orientation: self.imageOrientation)
        
        return cropped
    }
}
