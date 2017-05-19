//
//  DetailEventViewController.swift
//  VaporTalk
//
//  Created by 이상윤 on 2017. 5. 19..
//  Copyright © 2017년 이상윤. All rights reserved.
//

import UIKit
import MapKit
import FirebaseStorageUI
import Firebase

class DetailEventViewController: UIViewController {

    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var eventContentLabel: UITextView!
    @IBOutlet weak var eventImgView: UIImageView!
    @IBOutlet weak var eventMapKit: MKMapView!
    @IBOutlet weak var remainEventTimerLabel: UILabel!
    @IBOutlet weak var eventTimestampLabel: UILabel!
    
    var event: Event?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUI()
    }
    
    func setUI() {
        self.navigationItem.title = "\((event?.hostName)!)"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backButtonTouched))
        
        eventTitleLabel.text = event?.title
        eventContentLabel.text = event?.content
        eventTimestampLabel.text = event?.timestamp
        setRemainTimer()
        setEventImage()
        setEventMap()
    }
    
    func setRemainTimer() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        let eventTimestamp = dateFormatter.date(from: (event?.timestamp!)!)
        let diffTime = Int(Date().timeIntervalSince(eventTimestamp!))
        let remainTime = Int((event?.timer!)!) - diffTime
        
        remainEventTimerLabel.text = getTimeString(seconds: remainTime)
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
    
    func setEventImage() {
        let storage = FIRStorage.storage()
        let imageRef = storage.reference(withPath: "event/\((event?.hostUID)!)/\((event?.imageUrl)!)")
        eventImgView.sd_setImage(with: imageRef, placeholderImage: #imageLiteral(resourceName: "NoImageAvailable"))
    }
    
    func setEventMap() {
        let location: CLLocationCoordinate2D = CLLocationCoordinate2DMake((event?.latitude!)!, (event?.longtitude!)!)
        
        let region = MKCoordinateRegionMakeWithDistance(location, 500, 500)
        self.eventMapKit.setRegion(region, animated: true)
    }
    
    func backButtonTouched() {
        self.dismiss(animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
