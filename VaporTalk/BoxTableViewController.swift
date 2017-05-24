//
//  BoxTableViewController.swift
//  VaporTalk
//
//  Created by 이상윤 on 2017. 4. 18..
//  Copyright © 2017년 이상윤. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import Firebase
import PopupDialog

class BoxTableViewController: UITableViewController, VaporListChangeDelegate {
    
    let model = VaporModel()
    var vapors: [String:[Vapor]] = [:]
    var nameArr: [String]?
    var profileImgArr: [UIImage]?
    var activeCountArr: [Int]?
    var notActiveCountArr: [Int]?
    var loadVaporIndicator: NVActivityIndicatorView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    
        model.vaporListChangeDelegate = self
        
        loadVaporIndicator?.startAnimating()
        model.fetchVapors()
    }
    
    func setUI() {
        let frame = CGRect(x: self.view.frame.width / 2 - 37.5, y: self.view.frame.height / 2 - 37.5, width: 75, height: 75)
        loadVaporIndicator = NVActivityIndicatorView(frame: frame, type: NVActivityIndicatorType.ballSpinFadeLoader, color: UIColor.blue, padding: 20)
        self.view.addSubview(loadVaporIndicator!)
        
        self.navigationItem.title = "베이퍼박스"
    }

    func didChange(_ vapors: [String:[Vapor]]) {
        self.vapors = vapors
        
        let keys = Array(vapors.keys)
        let ref = FIRDatabase.database().reference()
        
        resetDataArray()
        
        if self.vapors.count > 0 {
            for uid in keys {
                let userRef = ref.child("users").child(uid)
                userRef.observeSingleEvent(of: .value, with: { (snapshot) in
                    let dic = snapshot.value as! [String: String]
                    self.nameArr?.append(dic["name"]!)
                    let storage = FIRStorage.storage()
                    let profileImageReference = storage.reference().child("profile/\(uid)")
                    
                    profileImageReference.data(withMaxSize: 1 * 1024 * 1024) { (data, error) -> Void in
                        if (error != nil) {
                            print(error ?? "")
                        } else {
                            self.profileImgArr?.append(UIImage(data: data!)!)
                            self.setActiveCount(uid)
                            
                            if self.notActiveCountArr?.count == keys.count {
                                self.tableView.reloadData()
                                self.loadVaporIndicator?.stopAnimating()
                            }
                        }
                    }
                })
            }
        }
        else {
            self.tableView.reloadData()
            self.loadVaporIndicator?.stopAnimating()
        }
    }
    
    func resetDataArray() {
        nameArr = [String]()
        profileImgArr = [UIImage]()
        activeCountArr = [Int]()
        notActiveCountArr = [Int]()
    }
    
    func setActiveCount(_ uid: String) {
        var activeCount = 0
        var notActiveCount = 0
        for vapor in self.vapors[uid]! {
            if vapor.isActive! {
                activeCount = activeCount + 1
            }
            else {
                notActiveCount = notActiveCount + 1
            }
        }
        self.activeCountArr?.append(activeCount)
        self.notActiveCountArr?.append(notActiveCount)
    }

    func showRemoveUserVaporConfirmDialog(animated: Bool = true, user: String) {
        let title = "베이퍼 삭제"
        let message = "베이퍼를 삭제하시겠습니까?"
        
        let popup = Popup.newPopup(title, message)
        let buttonOne = CancelButton(title: "CANCEL") { }
        
        let buttonTwo = DefaultButton(title: "OK") {
            self.loadVaporIndicator?.startAnimating()
            self.model.removeUserVapor(user)
        }
        
        popup.addButtons([buttonOne, buttonTwo])
        self.present(popup, animated: animated, completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DetailVaporSegue" {
            let detailVaporVC = (((segue.destination as! DetailVaporViewController).viewControllers.first) as! DetailVaporTableViewController)
            detailVaporVC.barTitle = nameArr?[(self.tableView.indexPathForSelectedRow)!.row]
            
            let keys = Array(vapors.keys)
            let uid = keys[(self.tableView.indexPathForSelectedRow)!.row]
            detailVaporVC.uid = uid
        }
    }

}

extension BoxTableViewController {
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if vapors.count > 0 {
            //self.tableView.separatorStyle = .singleLine
            return 1
        }
        else {
            //self.tableView.separatorStyle = .none
            return 0;
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vapors.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BoxCell", for: indexPath) as! BoxTableViewCell
        
        if vapors.count > 0 {
            cell.friendNameLabel.text = nameArr?[indexPath.row]
            cell.friendProfileImgView.image = profileImgArr?[indexPath.row]
            cell.activeVaporCountLabel.text = "\((activeCountArr?[indexPath.row])!)"
            cell.notActiveVaporCountLabel.text = "\((notActiveCountArr?[indexPath.row])!)"
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (action, index) in
            let keys = Array(self.vapors.keys)
            self.showRemoveUserVaporConfirmDialog(animated: true, user: keys[indexPath.row])
        }
        return [deleteAction]
    }
}
