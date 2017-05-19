//
//  FriendTableViewController.swift
//  VaporTalk
//
//  Created by 이상윤 on 2017. 4. 7..
//  Copyright © 2017년 이상윤. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorageUI
import GoogleSignIn
import KCFloatingActionButton
import NVActivityIndicatorView
import PopupDialog
import CoreLocation

class FriendTableViewController: UITableViewController, UITextFieldDelegate, NVActivityIndicatorViewable, CLLocationManagerDelegate {

    let model = UserModel()
    let manager = CLLocationManager()
    
    let sections = ["내 프로필", "친구"]
    var friends = [Friend]()
    var filterFriends = [Friend]()
    
    var friendLoadIndicator: NVActivityIndicatorView?
    let searchController = UISearchController(searchResultsController: nil)

    override func viewWillAppear(_ animated: Bool) {
        friends = model.getFriends()
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }
    
    func setUI() {
        let frame = CGRect(x: self.view.frame.width / 2 - 37.5, y: self.view.frame.height / 2 - 87.5, width: 75, height: 75)
        friendLoadIndicator = NVActivityIndicatorView(frame: frame, type: NVActivityIndicatorType.ballPulseSync, color: UIColor.blue, padding: 20)
        self.view.addSubview(friendLoadIndicator!)
        
        self.navigationItem.title = "친구"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addFriendTouched))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Send", style: .plain, target: self, action: #selector(sendVaporTouched))
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters

        if UserDefaults.standard.object(forKey: "isNearAgree") as! String == "true" {
            manager.requestWhenInUseAuthorization()
        }
        
        if CLLocationManager.locationServicesEnabled() {
            manager.startUpdatingLocation()
        }
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
            self.model.removeFriend(friend)
            self.friends = self.model.getFriends()
            self.tableView.reloadData()
        }
        
        popup.addButtons([buttonOne, buttonTwo])
        self.present(popup, animated: animated, completion: nil)
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
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
    
    // 친구 삭제. 베이퍼 다이렉트 전송 넣어야 함.
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
        let storage = FIRStorage.storage()
        
        if indexPath.section == 0 {
            cell.nameLabel.text! = UserDefaults.standard.object(forKey: "name") as! String
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
        }
        
        let profileImageReference = storage.reference(withPath: "default-user.png")
        cell.profileImgView.sd_setImage(with: profileImageReference, placeholderImage: #imageLiteral(resourceName: "default-user"))
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = UserDefaults.standard
        let storage = FIRStorage.storage()
        
        var profileData = [String: String]()
        
        if indexPath.section == 0 {
            profileData = ["uid": user.object(forKey: "uid") as! String, "name": user.object(forKey: "name") as! String, "email": user.object(forKey: "email") as! String, "profileImage": user.object(forKey: "profileImage") as! String]
        }
        else {
            var friend: Friend
            if searchController.isActive && searchController.searchBar.text != "" {
                friend = filterFriends[(self.tableView.indexPathForSelectedRow)!.row]
            }
            else {
                friend = friends[(self.tableView.indexPathForSelectedRow)!.row]
            }
            profileData = ["uid": friend.uid!, "name": friend.name!, "email": friend.email!, "profileImage": friend.profileImage!]
        }
        
        let islandRef = storage.reference(withPath: "default-user.png")
        
        islandRef.data(withMaxSize: 1 * 128 * 128) { (data, error) -> Void in
            if error != nil {
                print(error ?? "")
                return
            } else {
                let image = UIImage(data: data!)
                let popup = Popup.newImagePopup(profileData["name"]!, profileData["email"]!, image!)
                
                let buttonOne = DefaultButton(title: "Send Vapor") {
                    self.performSegue(withIdentifier: "SendVaporSegue", sender: profileData)
                }
                
                let buttonTwo = CancelButton(title: "CANCEL") { }
                
                popup.addButtons([buttonOne, buttonTwo])
                
                self.present(popup, animated: true, completion: nil)
            }
        }
        self.tableView.deselectRow(at: indexPath, animated: true)
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
