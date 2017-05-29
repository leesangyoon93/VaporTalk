//
//  CommerceTableViewController.swift
//  VaporTalk
//
//  Created by 이상윤 on 2017. 5. 21..
//  Copyright © 2017년 이상윤. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import Firebase

class CommerceTableViewController: UITableViewController, CommerceChangeDelegate {
    
    var loadCommerceIndicator: NVActivityIndicatorView?
    let commerceModel = CommerceModel()
    var commerces = [Event]()

    override func viewDidLoad() {
        super.viewDidLoad()

        setUI()
        loadCommerceIndicator?.startAnimating()
        commerceModel.fetchCommerces()
        commerceModel.commerceChangeDelegate = self
    }
    
    func setUI() {
        let frame = CGRect(x: self.view.frame.width / 2 - 37.5, y: self.view.frame.height / 2 - 37.5, width: 75, height: 75)
        loadCommerceIndicator = NVActivityIndicatorView(frame: frame, type: NVActivityIndicatorType.ballSpinFadeLoader, color: UIColor.blue, padding: 20)
        self.view.addSubview(loadCommerceIndicator!)
        
        self.navigationItem.title = "타임 커머스"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Send(임시)", style: .plain, target: self, action: #selector(sendCommerceTouched))
    }
    
    // 임시 코드
    func sendCommerceTouched() {
        let imageName = Int(Date.timeIntervalSinceReferenceDate * 1000)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"

        let commerce = Event(hostUID: UserDefaults.standard.object(forKey: "uid") as! String, hostName: "롯데리아(경기대역점)", title: "불고기버거 떨이", content: "매장 영업 종료 전 잔여 불고기버거 1000원에 판매합니다.", imageUrl: "\(imageName)", timer: 60, latitude: 37.27908944301991, longtitude: 127.0437736974064, location: "경기도 수원시 영통구 이의동 795-4", timestamp: dateFormatter.string(from: Date()))
        let commerceData = CommerceAnalysis(type: "패스트푸드", keyword: "햄버거, 패스트푸드, 불고기버거")
        commerceModel.sendCommerce(commerce: commerce, commerceData: commerceData, commerceImage: #imageLiteral(resourceName: "NoImageAvailable"))
    }

    func didChange(_ commerces: [Event]) {
        self.commerces = commerces
        self.tableView.reloadData()
        loadCommerceIndicator?.stopAnimating()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DetailCommerceSegue" {
            let detailCommerceVC = ((segue.destination as! DetailCommerceNavigationViewController).viewControllers.first) as! DetailCommerceViewController
            detailCommerceVC.commerce = commerces[(self.tableView.indexPathForSelectedRow)!.row]
        }
    }
}

extension CommerceTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commerces.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommerceCell", for: indexPath) as! CommerceTableViewCell
        
        if commerces.count > 0 {
            cell.commerceTitleLabel.text = commerces[indexPath.row].title
            cell.commerceLocationLabel.text = commerces[indexPath.row].location
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
    }

}
