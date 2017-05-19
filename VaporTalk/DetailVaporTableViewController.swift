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

class DetailVaporTableViewController: UITableViewController, VaporChangeDelegate {

    let model = VaporModel()
    var contentImgView: UIImageView?
    var uid: String?
    var barTitle: String?
    var vapors = [Vapor]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        model.vaporChangeDelegate = self
        
        model.fetchDetailVapors(uid!)
        sortVapor()
        setUI()
    }
    
    func didUpdated() {
        self.vapors = model.getDetailVapors(uid!)
        sortVapor()
    }
    
    func sortVapor() {
        vapors.sort { (object1, object2) -> Bool in
            if object1.isActive! == object2.isActive! {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
                let object1Timestamp = dateFormatter.date(from: object1.timestamp!)
                let object2Timestamp = dateFormatter.date(from: object2.timestamp!)
                let diffTime1 = Int(Date().timeIntervalSince(object1Timestamp!))
                let diffTime2 = Int(Date().timeIntervalSince(object2Timestamp!))
                let remainTime1 = "\(Int(object1.timer!) - diffTime1)"
                let remainTime2 = "\(Int(object2.timer!) - diffTime2)"
                return remainTime1 < remainTime2
            }
            else {
                return object1.isActive! == true
            }
        }
        self.tableView.reloadData()
    }
    
    func setUI() {
        self.tableView.separatorStyle = .singleLine
        self.navigationItem.title = barTitle
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backButtonTouched))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Refresh", style: .plain, target: self, action: #selector(refreshButtonTouched))
    }
    
    func backButtonTouched() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func refreshButtonTouched() {
        sortVapor()
    }

    
//    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        cell.contentView.backgroundColor = UIColor.clear
//        
//        let whiteRoundedView : UIView = UIView(frame: CGRect(x: 10, y: 10, width: self.view.frame.size.width - 20, height: 140))
//        
//        whiteRoundedView.layer.backgroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [1.0, 1.0, 1.0, 1.0])
//        whiteRoundedView.layer.masksToBounds = false
//        whiteRoundedView.layer.cornerRadius = 2.0
//        whiteRoundedView.layer.shadowOffset = CGSize(width: -1, height: 1)
//        whiteRoundedView.layer.shadowOpacity = 0.2
//        
//        cell.contentView.addSubview(whiteRoundedView)
//        cell.contentView.sendSubview(toBack: whiteRoundedView)
//    }

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
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        let vaporTimestamp = dateFormatter.date(from: vapors[indexPath.row].timestamp!)
        let diffTime = Int(Date().timeIntervalSince(vaporTimestamp!))
        let remainTime = Int(vapors[indexPath.row].timer!) - diffTime
        
        setCellAttr(cell, vapors[indexPath.row].isActive!)
        
        if vapors[indexPath.row].isActive! {
            cell.vaporTimestampLabel.text = vapors[indexPath.row].timestamp!
            cell.remainTimerLabel.text = getTimeString(seconds: remainTime)
            
            let storage = FIRStorage.storage()
            let contentsRef = storage.reference(withPath: "vapor/\(UserDefaults.standard.object(forKey: "uid") as! String)/\(uid!)/\(vapors[indexPath.row].contents!)")
            cell.contentImgView.sd_setImage(with: contentsRef, placeholderImage: #imageLiteral(resourceName: "NoImageAvailable"))
        }
        else {
            cell.logLabel.text = "\(getTimeString(seconds: diffTime)) 전에 베이퍼가 왔었습니다."
        }
        
        return cell
    }
    
    func setCellAttr(_ cell: DetailVaporTableViewCell, _ flag: Bool) {
        cell.logLabel.isHidden = flag
        cell.vaporTimestampLabel.isHidden = !flag
        cell.remainTimerTitleLabel.isHidden = !flag
        cell.remainTimerLabel.isHidden = !flag
        cell.contentImgView.isHidden = !flag
    }
    
    func getTimeString(seconds: Int) -> String {
        let (h,m,_) = secondsToHoursMinutesSeconds(seconds: seconds)
        var timeString = ""
        if h > 0 {
            timeString = "\(h)시간 "
        }
        timeString = timeString + "\(m)분"
        return timeString
    }
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160.0
    }

}
