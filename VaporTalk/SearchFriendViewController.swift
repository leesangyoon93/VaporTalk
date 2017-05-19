//
//  SearchFriendViewController.swift
//  VaporTalk
//
//  Created by 이상윤 on 2017. 4. 14..
//  Copyright © 2017년 이상윤. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorageUI
import PopupDialog
import NVActivityIndicatorView

class SearchFriendViewController: UIViewController {

    let model = UserModel()
    
    @IBOutlet weak var friendSearchBar: UISearchBar!
    @IBOutlet weak var searchTableView: UITableView!
    var friendLoadIndicator: NVActivityIndicatorView?
    var friends = [Friend]()
    var searchResults = [Anonymous]()
    var anonymousList = [Anonymous]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        friends = model.getFriends()
        setUI()
    }
    
    func setUI() {
        searchTableView.delegate = self
        searchTableView.dataSource = self
        
        let frame = CGRect(x: self.view.frame.width / 2 - 37.5, y: self.view.frame.height / 2 - 87.5, width: 75, height: 75)
        friendLoadIndicator = NVActivityIndicatorView(frame: frame, type: NVActivityIndicatorType.ballPulseSync, color: UIColor.blue, padding: 20)
        self.view.addSubview(friendLoadIndicator!)
        
        self.navigationItem.title = "친구검색"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backButtonTouched))
        friendSearchBar.becomeFirstResponder()
    }
    
    func backButtonTouched() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func addFriendButtonTouched(sender: UIButton) {
        var anonymous = self.searchResults[sender.tag]
        let title = "친구 추가 확인"
        let message = "\(anonymous.name!) 님을 친구로 등록하시겠습니까?"
        
        let popup = Popup.newPopup(title, message)
        let buttonOne = CancelButton(title: "CANCEL") { }
        
        let buttonTwo = DefaultButton(title: "OK") {
            self.model.addFriend(anonymous)
            anonymous.setIsFriend(true)
            self.searchTableView.reloadData()
        }
        
        popup.addButtons([buttonOne, buttonTwo])
        self.present(popup, animated: true, completion: nil)
    }
}

extension SearchFriendViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if searchResults.count > 0 {
            return 1
        }
        else {
            let rect = CGRect(x: 0, y: 0,
                              width: self.searchTableView.bounds.size.width,
                              height: self.searchTableView.bounds.size.height)
            let noDataLabel: UILabel = UILabel(frame: rect)
            
            noDataLabel.text = "검색 결과가 없습니다."
            noDataLabel.textColor = UIColor.black
            noDataLabel.textAlignment = .center
            self.searchTableView.backgroundView = noDataLabel
            self.searchTableView.separatorStyle = .none
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchFriendCell", for: indexPath) as! SearchTableViewCell
        let storage = FIRStorage.storage()
        let anonymous = searchResults[indexPath.row]
        let profileImageReference = storage.reference(withPath: "default-user.png")
        
        cell.searchFriendProfileImage.sd_setImage(with: profileImageReference, placeholderImage: #imageLiteral(resourceName: "circle-user-7.png"))
        cell.searchFriendNameLabel.text = anonymous.name!
        cell.searchFriendEmailLabel.text = anonymous.email!
        
        if anonymous.isFriend! {
            cell.addFriendButton.setTitle("베프", for: UIControlState())
        }
        else {
            cell.addFriendButton.setTitle("추가", for: UIControlState())
            cell.addFriendButton.addTarget(self, action: #selector(addFriendButtonTouched), for: .touchUpInside)
        }
        
        cell.addFriendButton.layer.masksToBounds = true
        cell.addFriendButton.tag = indexPath.row
        
        return cell
    }
}

extension SearchFriendViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        friendLoadIndicator?.startAnimating()
        
        self.searchResults.removeAll()
        
        for anonymous in anonymousList {
            var anonymousUser = anonymous
            for friend in self.friends {
                if anonymousUser.UID! == friend.uid {
                    anonymousUser.setIsFriend(true)
                }
            }
            if anonymousUser.email!.lowercased().contains((searchBar.text?.lowercased())!)
                && anonymousUser.UID! != (UserDefaults.standard.object(forKey: "uid") as! String) {
                self.searchResults.append(anonymousUser)
            }
        }
        self.searchTableView.reloadData()
        self.friendLoadIndicator?.stopAnimating()
        self.view.endEditing(true)
    }

}
