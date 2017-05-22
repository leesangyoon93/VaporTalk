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
        loadEventIndicator?.stopAnimating()
        self.tableView.reloadData()
    }
    
    func sendEventTouched() {
        self.performSegue(withIdentifier: "SendEventSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DetailEventSegue" {
            let detailEventVC = (segue.destination as! DetailEventNavigationViewController).viewControllers.first as! DetailEventViewController
            detailEventVC.event = events[(self.tableView.indexPathForSelectedRow)!.row]
        }
    }

}

extension EventTableViewController {
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
}
