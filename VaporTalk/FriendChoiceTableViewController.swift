//
//  FriendChoiceTableViewController.swift
//  VaporTalk
//
//  Created by 이상윤 on 2017. 4. 17..
//  Copyright © 2017년 이상윤. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import Firebase
import FirebaseStorageUI

class FriendChoiceTableViewController: UITableViewController, UISearchResultsUpdating, SendCompleteDelegate {

    let vaporModel = VaporModel()
    var sendVaporIndicator: NVActivityIndicatorView?
    var friends = [Friend]()
    var filterFriends = [Friend]()
    var selectedFriends = [Friend]()
    let searchController = UISearchController(searchResultsController: nil)
    var selectImage: UIImage?
    var timer: Double?
    var completeCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let model = UserModel()
        friends = model.getFriends()
        
        setUI()
        vaporModel.sendCompleteDelegate = self
    }
    
    func setUI() {
        let frame = CGRect(x: self.view.frame.width / 2 - 37.5, y: self.view.frame.height / 2 - 87.5, width: 75, height: 75)
        sendVaporIndicator = NVActivityIndicatorView(frame: frame, type: NVActivityIndicatorType.lineSpinFadeLoader, color: UIColor.lightGray, padding: 20)
        self.view.addSubview(sendVaporIndicator!)
        
        self.navigationItem.title = "친구선택"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "back_white"), style: .plain, target: self, action: #selector(backButtonTouched))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "send_white"), style: .plain, target: self, action: #selector(sendVaporTouched))
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
    }
    
    func backButtonTouched() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func sendVaporTouched() {
        sendVaporIndicator?.startAnimating()
        
        for target in selectedFriends {
            let imageName = Int(Date.timeIntervalSinceReferenceDate * 1000)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
            
            let vapor = Vapor(UserDefaults.standard.object(forKey: "uid") as! String, target.uid!, "\(imageName)", self.timer!, true, dateFormatter.string(from: Date()))
            
            vaporModel.sendVapor(vapor: vapor, vaporImage: selectImage!)
        }
    }
    
    func didComplete() {
        completeCount = completeCount + 1
        if completeCount == self.selectedFriends.count {
            self.sendVaporIndicator?.stopAnimating()
            self.showAlertDialog(title: "베이퍼 전송 완료", message: "친구들에게 베이퍼 전송이 완료되었습니다.")
        }
    }
    
    func showAlertDialog(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "확인", style: .default) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(defaultAction)
        
        self.present(alertController, animated: true, completion: nil)
    }

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

extension FriendChoiceTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if self.friends.count > 0 {
            return 1
        }
        else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filterFriends.count
        }
        return friends.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendChoiceCell", for: indexPath) as! FriendChoiceTableViewCell
        
        let friend: Friend
        if searchController.isActive && searchController.searchBar.text != "" {
            friend = filterFriends[indexPath.row]
        }
        else {
            friend = friends[indexPath.row]
        }
        
        cell.friendNameLabel.text = friend.name!
        cell.friendProfileImgView.image = friend.profileImage as? UIImage
        
        cell.checkButton.layer.cornerRadius = cell.checkButton.frame.width / 2.0
        cell.checkButton.layer.masksToBounds = true
        cell.checkButton.tag = indexPath.row
        cell.checkButton.addTarget(self, action: #selector(checkButtonToggle), for: .touchUpInside)
        
        if selectedFriends.contains(friend) {
            cell.checkButton.setBackgroundImage(#imageLiteral(resourceName: "check_yes"), for: UIControlState())
        }
        else {
            cell.checkButton.setBackgroundImage(#imageLiteral(resourceName: "check_no"), for: UIControlState())
        }
        
        return cell
    }
    
    func checkButtonToggle(sender: UIButton) {
        let value = sender.tag;
        
        let friend: Friend
        if searchController.isActive && searchController.searchBar.text != "" {
            friend = filterFriends[value]
        }
        else {
            friend = friends[value]
        }
        
        if selectedFriends.contains(friend) {
            selectedFriends.remove(at: selectedFriends.index(of: friend)!)
        }
        else {
            selectedFriends.append(friend)
        }
        self.tableView.reloadData()
    }
}
