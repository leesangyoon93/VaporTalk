//
//  AdditionalDataViewController.swift
//  VaporTalk
//
//  Created by 이상윤 on 2017. 4. 4..
//  Copyright © 2017년 이상윤. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Firebase
import GoogleSignIn
import NVActivityIndicatorView

class AdditionalDataViewController: UIViewController, UITextViewDelegate, UploadCompleteDelegate, UITextFieldDelegate, RegisterSuccessDelegate {

    var credentials: FIRAuthCredential?
    var gender: String = "male"
    var userData: [String:String] = [:]
    var token: String?
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var telTextField: UITextField!
    @IBOutlet weak var birthdayTextField: UITextField!
    @IBOutlet weak var genderTextField: UITextField!
    var registerIndicator: NVActivityIndicatorView?
    
    let userModel = UserModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        birthdayTextField.delegate = self
        genderTextField.delegate = self
        userModel.uploadCompleteDelegate = self
        userModel.registerSuccessDelegate = self
        
        setUI()
    }
    
    func setUI() {
        startButton.layer.cornerRadius = 5
        startButton.layer.masksToBounds = true
        nameTextField.becomeFirstResponder()
        
        let frame = CGRect(x: self.view.frame.width / 2 - 37.5, y: self.view.frame.height / 2 - 87.5, width: 75, height: 75)
        registerIndicator = NVActivityIndicatorView(frame: frame, type: NVActivityIndicatorType.lineSpinFadeLoader, color: UIColor.lightGray, padding: 20)
        self.view.addSubview(registerIndicator!)
        
        self.navigationItem.title = "추가정보 입력"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "back_white"), style: .plain, target: self, action: #selector(backButtonTouched))
    }
    
    func backButtonTouched() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func birthdayTextFieldChanged(_ sender: Any) {
        if birthdayTextField.text!.characters.count == 6 {
            if genderTextField.text!.characters.count != 1 {
                genderTextField.becomeFirstResponder()
            }
            else {
                view.self.endEditing(true)
            }
        }
    }
    @IBAction func genderTextFieldChanged(_ sender: Any) {
        if genderTextField.text == "1" || genderTextField.text == "2" {
            if genderTextField.text!.characters.count == 1 {
                view.self.endEditing(true)
            }
        }
        else {
            genderTextField.text = ""
        }
    }
    
    @IBAction func startButtonTouched(_ sender: Any) {
        registerIndicator?.startAnimating()
        self.view.endEditing(true)
        
        guard let name = nameTextField.text, let tel = telTextField.text, let birthday = birthdayTextField.text else {
            showAlertDialog(title: "Register Alert", message: "입력 정보를 모두 입력해주세요")
            return
        }
        
        UserDefaults.standard.set(true, forKey: "register")
        setGender()
        
        FIRAuth.auth()?.signIn(with: self.credentials!, completion: { ( user, error) in
            if error != nil {
                return
            }
            self.userData = ["uid": (user?.uid)!, "email": (user?.email)!, "name": name, "tel": tel, "gender": self.gender, "birthday": birthday]
            
            let ref = FIRDatabase.database().reference()
            let socialRef = ref.child("social").childByAutoId()
            socialRef.setValue(self.token!)
            
            self.userModel.updateProfileImage(#imageLiteral(resourceName: "default-user"), (user?.uid)!)
        })
    }
    
    func moveMainVC() {
        UserDefaults.standard.set(false, forKey: "register")
        UserDefaults.standard.set(self.userData["uid"]!, forKey: "lastUid")
        
        let mainViewController = self.storyboard?.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = mainViewController
    }
    
    func didComplete(_ profileImage: UIImage) {
        userModel.register(userData, UIImageJPEGRepresentation(profileImage, 0.1)!)
    }
    
    func didSuccess(_ userData: [String : String], _ profileData: Data) {
        self.registerIndicator?.stopAnimating()
        moveMainVC()
    }
    
    func setGender() {
        if genderTextField.text == "1" {
            gender = "male"
        }
        else if genderTextField.text == "2" {
            gender = "female"
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if nameTextField.isEditing {
            telTextField.becomeFirstResponder()
        }
        else if telTextField.isEditing {
            birthdayTextField.becomeFirstResponder()
        }
        else if birthdayTextField.isEditing {
            genderTextField.becomeFirstResponder()
        }
        else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func showAlertDialog(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "Close Alert", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        
        self.present(alertController, animated: true, completion: nil)
    }

}
