//
//  DetailVaporTableViewController.swift
//  VaporTalk
//
//  Created by 이상윤 on 2017. 4. 20..
//  Copyright © 2017년 이상윤. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorageUI

class DetailVaporTableViewController: UITableViewController, DetailVaporChangeDelegate {

    let model = VaporModel()
    var contentImgView: UIImageView?
    var uid: String?
    var barTitle: String?
    var vapors = [Vapor]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        model.detailVaporChangeDelegate = self
        
        model.fetchDetailVapors(uid!)
        setUI()
    }
    
    func didChange(_ vapors: [Vapor]) {
        self.vapors = vapors
        self.tableView.reloadData()
    }
    
    func setUI() {
        self.tableView.separatorStyle = .singleLine
        self.navigationItem.title = barTitle
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "back_white"), style: .plain, target: self, action: #selector(backButtonTouched))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "refresh"), style: .plain, target: self, action: #selector(refreshButtonTouched))
    }
    
    func backButtonTouched() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func refreshButtonTouched() {
        model.fetchDetailVapors(uid!)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DetailImageSegue" {
            (segue.destination as! DetailImageViewController).detailImg = sender as? UIImage
        }
    }
}

extension DetailVaporTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vapors.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DetailVaporCell", for: indexPath) as! DetailVaporTableViewCell
        
        setCellAttr(cell, vapors[indexPath.row].isActive!)
        
        if vapors[indexPath.row].isActive! {
            cell.vaporTimestampLabel.text = vapors[indexPath.row].timestamp!
            cell.remainTimerLabel.text = vapors[indexPath.row].getActiveVaporTime()
            let storage = FIRStorage.storage()
            let contentsRef = storage.reference(withPath: "vapor/\(UserDefaults.standard.object(forKey: "uid") as! String)/\(uid!)/\(vapors[indexPath.row].contents!)")
            cell.contentImgView.sd_setImage(with: contentsRef, placeholderImage: #imageLiteral(resourceName: "NoImageAvailable"))
        }
        else {
            cell.logLabel.text = "\(vapors[indexPath.row].getNotActiveVaporTime()) 전에 베이퍼가 도착했습니다"
        }
        
        return cell
    }
    
    func setCellAttr(_ cell: DetailVaporTableViewCell, _ flag: Bool) {
        cell.logLabel.isHidden = flag
        cell.timerImgView.isHidden = !flag
        cell.timestampImgView.isHidden = !flag
        cell.vaporTimestampLabel.isHidden = !flag
        cell.remainTimerLabel.isHidden = !flag
        cell.contentImgView.isHidden = !flag
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160.0
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell = self.tableView.cellForRow(at: indexPath) as! DetailVaporTableViewCell
        self.tableView.deselectRow(at: indexPath, animated: true)
        if selectedCell.logLabel.isHidden {
            self.performSegue(withIdentifier: "DetailImageSegue", sender: selectedCell.contentImgView.image)
        }
    }
}
