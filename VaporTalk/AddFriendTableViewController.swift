//
//  AddFriendTableViewController.swift
//  VaporTalk
//
//  Created by 이상윤 on 2017. 4. 7..
//  Copyright © 2017년 이상윤. All rights reserved.
//

import UIKit
import Contacts
import Firebase
import FirebaseStorageUI
import NVActivityIndicatorView
import PopupDialog

class AddFriendTableViewController: UITableViewController, UISearchResultsUpdating {
    
    let model = UserModel()
    
    var friends = [Friend]()
    var anonymousList = [Anonymous]()
    var friendLoadIndicator: NVActivityIndicatorView?
    var contacts = [Anonymous]()
    var filterContacts = [Anonymous]()
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        friends = model.getFriends()
        findContacts()
    }

    func setUI() {
        let frame = CGRect(x: self.view.frame.width / 2 - 37.5, y: self.view.frame.height / 2 - 87.5, width: 75, height: 75)
        friendLoadIndicator = NVActivityIndicatorView(frame: frame, type: NVActivityIndicatorType.ballPulseSync, color: UIColor.blue, padding: 20)
        self.view.addSubview(friendLoadIndicator!)
        self.navigationItem.title = "친구추가(연락처)"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backButtonTouched))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Search", style: .plain, target: self, action: #selector(searchFriendTouched))
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filterFriendForSearchText(searchText: searchController.searchBar.text!)
    }
    
    func filterFriendForSearchText(searchText: String) {
        self.filterContacts = contacts.filter({ (contact) -> Bool in
            return contact.getName().contains(searchText) })
        tableView.reloadData()
    }
    
    func searchFriendTouched() {
        self.performSegue(withIdentifier: "SearchFriendSegue", sender: nil)
    }

    func backButtonTouched() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func addFriendButtonTouched(sender: UIButton) {
        let anonymous = self.contacts[sender.tag]
        let title = "친구 추가 확인"
        let message = "\(anonymous.getName()) 님을 친구로 등록하시겠습니까?"
        
        let popup = Popup.newPopup(title, message)
        let buttonOne = CancelButton(title: "CANCEL") { }
        
        let buttonTwo = DefaultButton(title: "OK") {
            self.model.addFriend(anonymous)
            anonymous.setIsFriend(true)
            self.tableView.reloadData()
        }
        
        popup.addButtons([buttonOne, buttonTwo])
        self.present(popup, animated: true, completion: nil)
    }
    
    
    func findContacts() {
        friendLoadIndicator?.startAnimating()
        
        let store = CNContactStore()
        store.requestAccess(for: .contacts, completionHandler: { granted, error in
            guard granted else {
                let alert = UIAlertController(title: "Can't access contact", message: "Please go to Settings -> MyApp to enable contact permission", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            let keysToFetch = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName), CNContactPhoneNumbersKey] as [Any]
            let request = CNContactFetchRequest(keysToFetch: keysToFetch as! [CNKeyDescriptor])
            var cnContacts = [CNContact]()
            
            do {
                try store.enumerateContacts(with: request) {
                    (contact, cursor) -> Void in
                    cnContacts.append(contact)
                }
            } catch let error {
                print("Fetch contact error: \(error)")
            }
            
            self.fetchAnonymous(cnContacts)
        })
    }
    
    func fetchAnonymous(_ cnContacts: [CNContact]) {
        let ref = FIRDatabase.database().reference()
        ref.child("users").observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
            if let dic = snapshot.value as? [String: AnyObject] {
                for (key, value) in dic {
                    let anonymous = Anonymous(UID: key, name: value["name"] as! String, email: value["email"] as! String,
                        profileImage: value["profileImage"] as! String, tel: value["tel"] as! String, isFriend: false)
                    
                    for friend in self.friends {
                        if anonymous.getUID() == friend.uid {
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
                self.sortContacts()
            }
            self.tableView.reloadData()
            self.friendLoadIndicator?.stopAnimating()
        })
    }
    
    func sortContacts() {
        self.contacts.sort { (object1, object2) -> Bool in
            if object1.getName() == object2.getName() {
                return object1.getTel() < object2.getTel()
            }
            else {
                return object1.getName() < object2.getName()
            }
        }
        self.anonymousList.sort { (object1, object2) -> Bool in
            if object1.getName() == object2.getName() {
                return object1.getTel() < object2.getTel()
            }
            else {
                return object1.getName() < object2.getName()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SearchFriendSegue" {
            (((segue.destination as! UINavigationController).viewControllers.first) as! SearchFriendViewController).anonymousList = self.anonymousList
        }
    }
}

extension AddFriendTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        if self.contacts.count > 0 {
            return 1
        }
        else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filterContacts.count
        }
        return contacts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddFriendCell", for: indexPath) as! AddFriendSearchTableViewCell
        
        let storage = FIRStorage.storage()
        
        let contact: Anonymous
        if searchController.isActive && searchController.searchBar.text != "" {
            contact = filterContacts[indexPath.row]
        }
        else {
            contact = contacts[indexPath.row]
        }
        
        cell.friendProfileNameLabel.text = contact.getName()
        let profileImageReference = storage.reference(withPath: "default-user.png")
        cell.friendProfileImageView.sd_setImage(with: profileImageReference, placeholderImage: #imageLiteral(resourceName: "circle-user-7.png"))
        
        if contact.getIsFriend() {
            cell.addFriendButton.setTitle("베프", for: UIControlState())
            cell.addFriendButton.removeTarget(self, action: #selector(addFriendButtonTouched), for: .touchUpInside)
        }
        else {
            cell.addFriendButton.setTitle("추가", for: UIControlState())
            cell.addFriendButton.addTarget(self, action: #selector(addFriendButtonTouched), for: .touchUpInside)
        }
        cell.addFriendButton.layer.cornerRadius = 5
        cell.addFriendButton.layer.masksToBounds = true
        cell.addFriendButton.tag = indexPath.row
        
        return cell
    }
}