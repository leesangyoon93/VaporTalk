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
        titleTextField.delegate = self
        contentTextView.delegate = self
        manager.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        manager.stopUpdatingLocation()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func setUI() {
        let frame = CGRect(x: self.view.frame.width / 2 - 37.5, y: self.view.frame.height / 2 - 87.5, width: 75, height: 75)
        sendEventIndicator = NVActivityIndicatorView(frame: frame, type: NVActivityIndicatorType.lineSpinFadeLoader, color: UIColor.lightGray, padding: 20)
        self.view.addSubview(sendEventIndicator!)
        
        self.navigationItem.title = "이벤트 전송"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "send_white"), style: .plain, target: self, action: #selector(sendEventTouched))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "back_white"), style: .plain, target: self, action: #selector(backButtonTouched))
        
        
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
        let imageName = Int(Date.timeIntervalSinceReferenceDate * 1000)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        
        if checkEventVaild() {
            sendEventIndicator?.startAnimating()
            
            let event = Event(hostUID: UserDefaults.standard.object(forKey: "uid") as! String, hostName: UserDefaults.standard.object(forKey: "name") as! String, title: titleTextField.text!, content: contentTextView.text, imageUrl: "\(imageName)", timer: eventTimePickerView.countDownDuration, latitude: lat!, longtitude: lon!, location: address!, timestamp: dateFormatter.string(from: Date()))
            
            eventModel.sendEvent(event: event, eventImage: eventImgView.image)
        }
        else {
            showInputAlertDialog(title: "내용 입력", message: "이벤트 제목과 내용을 모두 입력해주세요.")
        }
    }
    
    func checkEventVaild() -> Bool {
        if titleTextField.text != "" && contentTextView.text != "" {
            return true
        }
        else {
            return false
        }
    }
    
    func didComplete() {
        sendEventIndicator?.stopAnimating()
        self.showCompleteEventDialog(title: "이벤트 전송 완료", message: "주변 사용자들에게 베이퍼 이벤트 전송이 완료되었습니다.")
    }
    
    func showCompleteEventDialog(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "확인", style: .default) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(defaultAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showInputAlertDialog(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "확인", style: .default) { (action) in
            if self.titleTextField.text == "" {
                self.titleTextField.resignFirstResponder()
            }
            else {
                self.contentTextView.resignFirstResponder()
            }
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
