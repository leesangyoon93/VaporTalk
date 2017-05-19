//
//  EventTableViewController.swift
//  VaporTalk
//
//  Created by 이상윤 on 2017. 5. 18..
//  Copyright © 2017년 이상윤. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import Firebase
import FirebaseStorageUI

class EventTableViewController: UITableViewController, EventChangeDelegate {

    var loadEventIndicator: NVActivityIndicatorView?
    let eventModel = EventModel()
    var events = [Event]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUI()
        loadEventIndicator?.startAnimating()
        eventModel.fetchEvents()
        eventModel.eventChangeDelegate = self
    }
    
    func setUI() {
        let frame = CGRect(x: self.view.frame.width / 2 - 37.5, y: self.view.frame.height / 2 - 37.5, width: 75, height: 75)
        loadEventIndicator = NVActivityIndicatorView(frame: frame, type: NVActivityIndicatorType.ballSpinFadeLoader, color: UIColor.blue, padding: 20)
        self.view.addSubview(loadEventIndicator!)
        
        self.navigationItem.title = "베이퍼 이벤트"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Send", style: .plain, target: self, action: #selector(sendEventTouched))
    }
    
    func didChange(_ events: [Event]) {
        self.events = events
        sortEvents()
        
    }
    
    func sortEvents() {
        events.sort { (object1, object2) -> Bool in
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
        loadEventIndicator?.stopAnimating()
        self.tableView.reloadData()
    }
    
    func sendEventTouched() {
        self.performSegue(withIdentifier: "SendEventSegue", sender: nil)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return events.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as! EventTableViewCell
        
        if events.count > 0 {
            cell.eventTitleLabel.text = events[indexPath.row].title
            cell.eventLocationLabel.text = events[indexPath.row].location
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DetailEventSegue" {
            let detailEventVC = (segue.destination as! DetailEventNavigationViewController).viewControllers.first as! DetailEventViewController
            detailEventVC.event = events[(self.tableView.indexPathForSelectedRow)!.row]
        }
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

}
