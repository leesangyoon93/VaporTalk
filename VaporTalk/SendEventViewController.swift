//
//  SendEventViewController.swift
//  VaporTalk
//
//  Created by 이상윤 on 2017. 5. 18..
//  Copyright © 2017년 이상윤. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import MapKit
import CoreLocation

class SendEventViewController: UIViewController, UITextFieldDelegate, EventImageChangeDelegate, SendCompleteDelegate {
    
    let eventModel = EventModel()

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var eventImgView: UIImageView!
    @IBOutlet weak var eventMapKit: MKMapView!
    @IBOutlet weak var uploadImgView: UIImageView!
    
    var sendEventIndicator: NVActivityIndicatorView?
    let eventTimePickerView: UIDatePicker = UIDatePicker()
    
    var lat: Double?
    var lon: Double?
    var address: String?
    
    let manager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUI()
        eventModel.sendCompleteDelegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func setUI() {
        let frame = CGRect(x: self.view.frame.width / 2 - 37.5, y: self.view.frame.height / 2 - 37.5, width: 75, height: 75)
        sendEventIndicator = NVActivityIndicatorView(frame: frame, type: NVActivityIndicatorType.ballSpinFadeLoader, color: UIColor.blue, padding: 20)
        self.view.addSubview(sendEventIndicator!)
        
        self.navigationItem.title = "이벤트 전송"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Send", style: .plain, target: self, action: #selector(sendEventTouched))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backButtonTouched))
        
        titleTextField.delegate = self
        contentTextView.delegate = self
        contentTextView.text = "이벤트 상세 내용"
        contentTextView.textColor = UIColor.lightGray
        contentTextView.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
        contentTextView.layer.borderWidth = 1.0
        contentTextView.layer.cornerRadius = 5
        
        eventImgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(takeEventPhoto)))
        uploadImgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(takeEventPhoto)))
        
        eventTimePickerView.frame = CGRect(x: 10, y: self.view.frame.height / 2, width: self.view.frame.width - 20, height: 130)
        eventTimePickerView.datePickerMode = UIDatePickerMode.countDownTimer
        eventTimePickerView.countDownDuration = 3600.0
        view.addSubview(eventTimePickerView)
        
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        manager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            manager.startUpdatingLocation()
        }
    }
    
    func takeEventPhoto() {
        self.performSegue(withIdentifier: "TakeEventPhotoSegue", sender: nil)
    }
    
    func sendEventTouched() {
        sendEventIndicator?.startAnimating()
        let imageName = Int(Date.timeIntervalSinceReferenceDate * 1000)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        
        let event = Event(hostUID: UserDefaults.standard.object(forKey: "uid") as! String, hostName: UserDefaults.standard.object(forKey: "name") as! String, title: titleTextField.text!, content: contentTextView.text, imageUrl: "\(imageName)", timer: eventTimePickerView.countDownDuration, latitude: lat!, longtitude: lon!, location: address!, timestamp: dateFormatter.string(from: Date()))
        
        eventModel.sendEvent(event: event, eventImage: eventImgView.image)
    }
    
    func didComplete() {
        sendEventIndicator?.stopAnimating()
        self.showAlertDialog(title: "이벤트 전송 완료", message: "주변 사용자들에게 베이퍼 이벤트 전송이 완료되었습니다.")
    }
    
    func showAlertDialog(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "확인", style: .default) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(defaultAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func didChange(selectImage: UIImage) {
        self.eventImgView.image = selectImage
        self.uploadImgView.isHidden = true
    }
    
    func backButtonTouched() {
        self.dismiss(animated: true, completion: nil)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TakeEventPhotoSegue" {
            let sendVaporVC = (segue.destination as! SendVaporViewController)
            sendVaporVC.sendType = "event"
            sendVaporVC.eventImageChangeDelegate = self
        }
    }
}

extension SendEventViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        
        lat = location.coordinate.latitude
        lon = location.coordinate.longitude
        let myLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(lat!, lon!)
        let region = MKCoordinateRegionMakeWithDistance(myLocation, 500, 500)
        
        self.eventMapKit.setRegion(region, animated: true)
        self.eventMapKit.showsUserLocation = true
        
        geocodeLocation()
    }
    
    func geocodeLocation() {
        let location: CLLocation = CLLocation(latitude: lat!, longitude: lon!)
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            if error != nil {
                print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                return
            }
            if (placemarks?.count)! > 0 {
                let pm = placemarks![0]
                self.address = "\(pm.country ?? "") \(pm.administrativeArea ?? "") \(pm.locality ?? "") \(pm.name ?? "")"
            }
            else {
                print("Problem with the data received from geocoder")
            }
        })
    }
}

extension SendEventViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if contentTextView.textColor == UIColor.lightGray {
            contentTextView.text = nil
            contentTextView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if contentTextView.text.isEmpty {
            contentTextView.text = "이벤트 상세 내용"
            contentTextView.textColor = UIColor.lightGray
        }
    }
    
}
