//
//  FriendTableViewController.swift
//  VaporTalk
//
//  Created by 이상윤 on 2017. 4. 7..
//  Copyright © 2017년 이상윤. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import KCFloatingActionButton
import NVActivityIndicatorView
import PopupDialog
import CoreLocation

class FriendTableViewController: UITableViewController, UITextFieldDelegate, NVActivityIndicatorViewable, CLLocationManagerDelegate, UpdateFriendCompleteDelegate {

    let userModel = UserModel()
    let manager = CLLocationManager()
    
    let sections = ["내 프로필", "친구"]
    var friends = [Friend]()
    var filterFriends = [Friend]()
    
    var friendLoadIndicator: NVActivityIndicatorView?
    let picker = UIImagePickerController()
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewWillAppear(_ animated: Bool) {
        self.friends = userModel.getFriends()
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        
        userModel.uploadCompleteDelegate = self
        userModel.updateFriendCompleteDelegate = self
        
        friendLoadIndicator?.startAnimating()
        userModel.setFriendsProfileImage()
        
        picker.delegate = self
        
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        
        if UserDefaults.standard.object(forKey: "isLocationAgree") as! String == "true" {
            manager.requestWhenInUseAuthorization()
        }
        
        if CLLocationManager.locationServicesEnabled() && UserDefaults.standard.object(forKey: "isLocationAgree") as! String == "true" {
            manager.startUpdatingLocation()
        }
        
        if UserDefaults.standard.object(forKey: "isPushAgree") as! String == "true" {
            updateUserFCM()
        }
    }
    
    func didUpdated(_ friends: [Friend]) {
        friendLoadIndicator?.stopAnimating()
        self.friends = friends
        self.tableView.reloadData()
    }
    
    func setUI() {
        let frame = CGRect(x: self.view.frame.width / 2 - 37.5, y: self.view.frame.height / 2 - 87.5, width: 75, height: 75)
        friendLoadIndicator = NVActivityIndicatorView(frame: frame, type: NVActivityIndicatorType.lineSpinFadeLoader, color: UIColor.lightGray, padding: 20)
        self.view.addSubview(friendLoadIndicator!)
        
        self.navigationItem.title = "친구"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "추가", style: .plain, target: self, action: #selector(addFriendTouched))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "send_white"), style: .plain, target: self, action: #selector(sendVaporTouched))
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        
        updateUserLocation(Double(location.coordinate.latitude), Double(location.coordinate.longitude))
    }
    
    func updateUserLocation(_ lat: Double, _ lon: Double) {
        let ref = FIRDatabase.database().reference()
        let userLocationRef = ref.child("locations").child(UserDefaults.standard.object(forKey: "uid") as! String)
        let locationValues = ["latitude": lat, "longtitude": lon]
        userLocationRef.updateChildValues(locationValues) { (error, ref) in
            self.manager.stopUpdatingLocation()
        }
    }
    
    func updateUserFCM() {
        let ref = FIRDatabase.database().reference()
        let userRef = ref.child("users").child(UserDefaults.standard.object(forKey: "uid") as! String)
        userRef.updateChildValues(["fcm": FIRInstanceID.instanceID().token() ?? ""])
    }
    
    func sendVaporTouched() {
        self.performSegue(withIdentifier: "SendVaporSegue", sender: nil)
    }
    
    func addFriendTouched() {
        self.performSegue(withIdentifier: "AddFriendSegue", sender: nil)
    }
    
    func showRemoveFriendConfirmDialog(animated: Bool = true, friend: Friend) {
        let title = "친구 삭제 확인"
        let message = "\(friend.name!) 님을 삭제 하시겠습니까?"
        
        let popup = Popup.newPopup(title, message)
        let buttonOne = CancelButton(title: "CANCEL") { }
        
        let buttonTwo = DefaultButton(title: "OK") {
            self.userModel.removeFriend(friend)
            self.friends = self.userModel.getFriends()
            self.tableView.reloadData()
        }
        
        popup.addButtons([buttonOne, buttonTwo])
        self.present(popup, animated: animated, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SendVaporSegue" {
            let sendVaporVC = segue.destination as! SendVaporViewController
            sendVaporVC.sendType = "vapor"
            if sender != nil {
                sendVaporVC.targetData = sender as? Dictionary
            }
        }
    }
}

extension FriendTableViewController {
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if indexPath.section == 1 {
            let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (action, index) in
                let friend = self.friends[indexPath.row]
                self.showRemoveFriendConfirmDialog(animated: true, friend: friend)
                
            }
            return [deleteAction]
        }
        return []
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.white
        let titleLabel = UILabel()
        titleLabel.frame = CGRect(x: 10, y: 5, width: 100, height: 25)
        titleLabel.text = sections[section]
        view.addSubview(titleLabel)
        
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        else {
            if searchController.isActive && searchController.searchBar.text != "" {
                return filterFriends.count
            }
            return friends.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell", for: indexPath) as! FriendTableViewCell
        
        if indexPath.section == 0 {
            cell.nameLabel.text! = UserDefaults.standard.object(forKey: "name") as! String
            cell.profileImgView.image = UIImage(data: UserDefaults.standard.object(forKey: "profileImage") as! Data)
        }
        else {
            let friend: Friend
            if searchController.isActive && searchController.searchBar.text != "" {
                friend = filterFriends[indexPath.row]
            }
            else {
                friend = friends[indexPath.row]
            }
            cell.nameLabel.text! = friend.name!
            cell.profileImgView.image = friend.profileImage as? UIImage
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = UserDefaults.standard
        var profileData = [String: String]()
        
        if indexPath.section == 0 {
            profileData = ["uid": user.object(forKey: "uid") as! String, "name": user.object(forKey: "name") as! String, "email": user.object(forKey: "email") as! String]
        }
        else {
            var friend: Friend
            if searchController.isActive && searchController.searchBar.text != "" {
                friend = filterFriends[(self.tableView.indexPathForSelectedRow)!.row]
            }
            else {
                friend = friends[(self.tableView.indexPathForSelectedRow)!.row]
            }
            profileData = ["uid": friend.uid!, "name": friend.name!, "email": friend.email!]
        }
        showProfilePopup(profileData, indexPath)
        
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func showProfilePopup(_ profileData: [String: String], _ indexPath: IndexPath) {
        
        var profileImage = UIImage(data: UserDefaults.standard.object(forKey: "profileImage") as! Data)
        if indexPath.section == 1 {
            profileImage = friends[indexPath.row].profileImage as? UIImage
        }
        
        let popup = Popup.newImagePopup(profileData["name"]!, profileData["email"]!, profileImage!)
        
        if indexPath.section == 0 {
            let uploadProfileImageButton = DefaultButton(title: "Update Profile Image") {
                self.picker.allowsEditing = false
                self.picker.sourceType = .photoLibrary
                self.picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
                self.present(self.picker, animated: true, completion: nil)
            }
            popup.addButton(uploadProfileImageButton)
        }
        
        let sendButton = DefaultButton(title: "Send Vapor") {
            self.performSegue(withIdentifier: "SendVaporSegue", sender: profileData)
        }
        
        let cancelButton = CancelButton(title: "CANCEL") { }
        
        popup.addButtons([sendButton, cancelButton])
        
        self.present(popup, animated: true, completion: nil)
    }
}

extension FriendTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterFriendForSearchText(searchText: searchController.searchBar.text!)
    }
    
    func filterFriendForSearchText(searchText: String) {
        self.filterFriends = friends.filter({ (friend) -> Bool in
            return (friend.name?.contains(searchText))!
        })
        tableView.reloadData()
    }
}

extension FriendTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate, UploadCompleteDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.dismiss(animated:true, completion: nil)
        friendLoadIndicator?.startAnimating()
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        self.userModel.updateProfileImage(chosenImage, UserDefaults.standard.object(forKey: "uid") as! String)
    }
    
    func didComplete(_ profileImage: UIImage) {
        friendLoadIndicator?.stopAnimating()
        UserDefaults.standard.set(UIImageJPEGRepresentation(profileImage, 0.5), forKey: "profileImage")
        self.tableView.reloadData()
        
    }
}
