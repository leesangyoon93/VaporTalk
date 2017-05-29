//
//  PhotoViewController.swift
//  VaporTalk
//
//  Created by 이상윤 on 2017. 4. 5..
//  Copyright © 2017년 이상윤. All rights reserved.
//

import UIKit
import Firebase
import NVActivityIndicatorView

class PhotoViewController: UIViewController, SendCompleteDelegate {
    
    let model = VaporModel()
    
    var selectImage: UIImage?
    var sendVaporIndicator: NVActivityIndicatorView?
    
    let vaporTimePickerView: UIDatePicker = UIDatePicker()
    let pickerBackgroundView: UIView = UIView()
    
    var vaporTimePickerIsHidden = false
    var targetData: [String:String]?
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    private var backgroundImage: UIImage
    
    init(image: UIImage) {
        self.selectImage = image
        self.backgroundImage = image
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func timePickerSwitchTouched() {
        self.vaporTimePickerView.isHidden = !vaporTimePickerIsHidden
        self.pickerBackgroundView.isHidden = !vaporTimePickerIsHidden
        vaporTimePickerIsHidden = !vaporTimePickerIsHidden
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        model.sendCompleteDelegate = self
        
        let frame = CGRect(x: self.view.frame.width / 2 - 37.5, y: self.view.frame.height / 2 - 37.5, width: 75, height: 75)
        sendVaporIndicator = NVActivityIndicatorView(frame: frame, type: NVActivityIndicatorType.ballSpinFadeLoader, color: UIColor.blue, padding: 20)

        self.view.backgroundColor = UIColor.gray
        let backgroundImageView = UIImageView(frame: view.frame)
        backgroundImageView.contentMode = UIViewContentMode.scaleAspectFill
        backgroundImageView.image = backgroundImage
        
        let cancelButton = UIButton(frame: CGRect(x: 10.0, y: 10.0, width: 30.0, height: 30.0))
        cancelButton.setImage(#imageLiteral(resourceName: "clear-button"), for: UIControlState())
        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        
        let okButton = UIButton(frame: CGRect(x: self.view.frame.width - 40, y: 10, width: 30, height: 30))
        okButton.setImage(#imageLiteral(resourceName: "send-button"), for: UIControlState())
        okButton.addTarget(self, action: #selector(sendButtonTouched), for: .touchUpInside)
        
        pickerBackgroundView.frame = CGRect(x: 10, y: self.view.frame.height - 200, width: self.view.frame.width / 1.5, height: 150)
        pickerBackgroundView.backgroundColor = UIColor.white
        pickerBackgroundView.alpha = 0.6
        pickerBackgroundView.layer.cornerRadius = 5
        pickerBackgroundView.layer.masksToBounds = true
        
        vaporTimePickerView.frame = CGRect(x: 20, y: self.view.frame.height - 190, width: self.view.frame.width / 1.5 - 20, height: 130)
        vaporTimePickerView.alpha = 0.8
        vaporTimePickerView.datePickerMode = UIDatePickerMode.countDownTimer
        vaporTimePickerView.countDownDuration = 300.0
        
        let vaporTimePickerSwitchButton = UIButton(frame: CGRect(x: 10, y: self.view.frame.height - 40, width: 30, height: 30))
        vaporTimePickerSwitchButton.setImage(#imageLiteral(resourceName: "alarm-clock"), for: UIControlState())
        vaporTimePickerSwitchButton.addTarget(self, action: #selector(timePickerSwitchTouched), for: .touchUpInside)
        
        view.addSubview(backgroundImageView)
        view.addSubview(pickerBackgroundView)
        view.addSubview(vaporTimePickerView)
        view.addSubview(vaporTimePickerSwitchButton)
        view.addSubview(okButton)
        view.addSubview(cancelButton)
        view.addSubview(sendVaporIndicator!)
    }
    
    func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    func sendButtonTouched() {
        if targetData != nil {
            sendVaporToFriend()
        }
        else {
            moveFriendChoiceVC()
        }
    }
    
    func sendVaporToFriend() {
        sendVaporIndicator?.startAnimating()
        
        let imageName = Int(Date.timeIntervalSinceReferenceDate * 1000)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        
        let vapor = Vapor(UserDefaults.standard.object(forKey: "uid") as! String, (self.targetData?["uid"])!, "\(imageName)", self.vaporTimePickerView.countDownDuration, true, dateFormatter.string(from: Date()))
        
        model.sendVapor(vapor: vapor, vaporImage: selectImage!)
    }
    
    func moveFriendChoiceVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let friendChoiceViewController = storyboard.instantiateViewController(withIdentifier: "FriendChoiceViewController") as! FriendChoiceViewController
        (friendChoiceViewController.viewControllers.first as! FriendChoiceTableViewController).selectImage = self.selectImage!
        (friendChoiceViewController.viewControllers.first as! FriendChoiceTableViewController).timer = self.vaporTimePickerView.countDownDuration
        self.present(friendChoiceViewController, animated: true, completion: nil)
    }
    
    func didComplete() {
        self.sendVaporIndicator?.stopAnimating()
        self.showAlertDialog(title: "베이퍼 전송 완료", message: "\((self.targetData?["name"])!) 님에게 베이퍼 전송이 완료되었습니다.")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
    
    func showAlertDialog(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "확인", style: .default) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(defaultAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
}
