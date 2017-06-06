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
        let frame = CGRect(x: self.view.frame.width / 2 - 37.5, y: self.view.frame.height / 2 - 87.5, width: 75, height: 75)
        loadCommerceIndicator = NVActivityIndicatorView(frame: frame, type: NVActivityIndicatorType.lineSpinFadeLoader, color: UIColor.lightGray, padding: 20)
        self.view.addSubview(loadCommerceIndicator!)
        
        self.navigationItem.title = "타임 커머스"
        if UserDefaults.standard.object(forKey: "name") as! String == "롯데리아" || UserDefaults.standard.object(forKey: "name") as! String == "이마트" {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "전송(임시)", style: .plain, target: self, action: #selector(sendCommerceTouched))
        }
    }
    
    func sendCommerceTouched() {
        self.performSegue(withIdentifier: "SendCommerceSegue", sender: nil)
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
            cell.commerceTimerLabel.text = commerces[indexPath.row].getRemainTime()
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
    }

}
