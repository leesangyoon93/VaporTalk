//
//  SendCommerceViewController.swift
//  VaporTalk
//
//  Created by 이상윤 on 2017. 6. 3..
//  Copyright © 2017년 이상윤. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class SendCommerceViewController: UIViewController, UITextFieldDelegate, SendCompleteDelegate {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextField: UITextView!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var categoryDivisionTextField: UITextField!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var itemTextField: UITextField!
    var sendCommerceIndicator: NVActivityIndicatorView?
    let commerceTimePickerView: UIDatePicker = UIDatePicker()
    
    let commerceModel = CommerceModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUI()
        commerceModel.sendCompleteDelegate = self
        // Do any additional setup after loading the view.
    }
    
    func setUI() {
        let frame = CGRect(x: self.view.frame.width / 2 - 37.5, y: self.view.frame.height / 2 - 87.5, width: 75, height: 75)
        sendCommerceIndicator = NVActivityIndicatorView(frame: frame, type: NVActivityIndicatorType.lineSpinFadeLoader, color: UIColor.lightGray, padding: 20)
        self.view.addSubview(sendCommerceIndicator!)
        
        self.navigationItem.title = "커머스 전송"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "send_white"), style: .plain, target: self, action: #selector(sendCommerceTouched))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "back_white"), style: .plain, target: self, action: #selector(backButtonTouched))
        
        contentTextField.text = "커머스 상세 내용"
        contentTextField.textColor = UIColor.lightGray
        contentTextField.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
        contentTextField.layer.borderWidth = 1.0
        contentTextField.layer.cornerRadius = 5
        
        commerceTimePickerView.frame = CGRect(x: 10, y: self.view.frame.height / 2, width: self.view.frame.width - 20, height: 130)
        commerceTimePickerView.datePickerMode = UIDatePickerMode.countDownTimer
        commerceTimePickerView.countDownDuration = 3600.0
        view.addSubview(commerceTimePickerView)
        
        titleTextField.becomeFirstResponder()
    }
    
    func sendCommerceTouched() {
        sendCommerceIndicator?.startAnimating()
        
        let imageName = Int(Date.timeIntervalSinceReferenceDate * 1000)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        
        let commerce = Event(hostUID: UserDefaults.standard.object(forKey: "uid") as! String, hostName: UserDefaults.standard.object(forKey: "name") as! String, title: titleTextField.text!, content: contentTextField.text!, imageUrl: "\(imageName)", timer: commerceTimePickerView.countDownDuration, latitude: 37.27908944301991, longtitude: 127.0437736974064, location: "경기도 수원시 영통구 이의동 795-4", timestamp: dateFormatter.string(from: Date()))
        let commerceData = CommerceAnalysis(category: categoryTextField.text!, item: itemTextField.text!, categoryDivision: categoryDivisionTextField.text!, price: Int(priceTextField.text!)!)
        commerceModel.sendCommerce(commerce: commerce, commerceData: commerceData, commerceImage: #imageLiteral(resourceName: "NoImageAvailable"))
    }
    
    func didComplete() {
        sendCommerceIndicator?.stopAnimating()
        self.dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if titleTextField.isEditing {
            contentTextField.becomeFirstResponder()
        }
        else if contentTextField.isFirstResponder {
            categoryTextField.becomeFirstResponder()
        }
        else if categoryTextField.isEditing {
            categoryDivisionTextField.becomeFirstResponder()
        }
        else if categoryDivisionTextField.isEditing {
            itemTextField.becomeFirstResponder()
        }
        else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func backButtonTouched() {
        self.dismiss(animated: true, completion: nil)
    }

}

extension SendCommerceViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if contentTextField.textColor == UIColor.lightGray {
            contentTextField.text = nil
            contentTextField.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if contentTextField.text.isEmpty {
            contentTextField.text = "이벤트 상세 내용"
            contentTextField.textColor = UIColor.lightGray
        }
    }
    
}
