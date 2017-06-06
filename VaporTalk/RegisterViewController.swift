//
//  RegisterViewController.swift
//  VaporTalk
//
//  Created by 이상윤 on 2017. 4. 3..
//  Copyright © 2017년 이상윤. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import NVActivityIndicatorView

class RegisterViewController: UIViewController, UITextFieldDelegate, UploadCompleteDelegate, RegisterSuccessDelegate {
    
    @IBOutlet weak var genderTagTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var telTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordCheckTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var birthdayTextField: UITextField!
    @IBOutlet weak var passwordCheckImgView: UIImageView!
    
    var registerIndicator: NVActivityIndicatorView?
    
    var userData: [String: String] = [:]
    var gender: String = "male"
    var isPasswordValid: Bool = false
    
    let userModel = UserModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userModel.uploadCompleteDelegate = self
        userModel.registerSuccessDelegate = self
        setUI()
    }
    
    func setUI() {
        registerButton.layer.cornerRadius = 5
        registerButton.layer.masksToBounds = true
        nameTextField.becomeFirstResponder()
        
        let frame = CGRect(x: self.view.frame.width / 2 - 37.5, y: self.view.frame.height / 2 - 87.5, width: 75, height: 75)
        registerIndicator = NVActivityIndicatorView(frame: frame, type: NVActivityIndicatorType.lineSpinFadeLoader, color: UIColor.lightGray, padding: 20)
        self.view.addSubview(registerIndicator!)
        
        self.navigationItem.title = "회원가입"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "back_white"), style: .plain, target: self, action: #selector(backButtonTouched))
    }
    
    func backButtonTouched() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func birthdayEditingChanged(_ sender: Any) {
        if birthdayTextField.text!.characters.count == 6 {
            if genderTagTextField.text!.characters.count != 1 {
                genderTagTextField.becomeFirstResponder()
            }
            else {
                emailTextField.becomeFirstResponder()
            }
        }
    }
    
    @IBAction func genderTagEditingChanged(_ sender: Any) {
        let genderText = genderTagTextField.text!
        if genderText == "1" || genderText == "2" {
            if genderText.characters.count == 1 {
                emailTextField.becomeFirstResponder()
            }
        }
        else {
            genderTagTextField.text = ""
        }
    }


    @IBAction func passwordCheckEditingChanged(_ sender: Any) {
        passwordCheckImgView.isHidden = false
        let currentPassword: String = passwordTextField.text!
        if passwordCheckTextField.text == currentPassword {
            passwordCheckImgView.image = #imageLiteral(resourceName: "join_password_correct_32")
            isPasswordValid = true
        }
        else {
            passwordCheckImgView.image = #imageLiteral(resourceName: "join_password_error_32")
            isPasswordValid = false
        }
    }
    
    @IBAction func registerButtonTouched(_ sender: Any) {
        registerIndicator?.startAnimating()
        self.view.endEditing(true)
        
        guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text, let tel = telTextField.text, let birthday = birthdayTextField.text else {
            showAlertDialog(title: "회원가입 오류", message: "입력 정보를 모두 입력해주세요")
            return
        }
        
        setGender()
        UserDefaults.standard.set(true, forKey: "register")
        
        if isPasswordValid {
            FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user: FIRUser?, error) in
                if error != nil {
                    self.registerIndicator?.stopAnimating()
                    self.showAlertDialog(title: "회원가입 오류", message: "이미 사용중인 이메일입니다.")
                    return
                }
            
                self.userData = ["uid": (user?.uid)!, "email": email, "password": password, "name": name, "tel": tel, "gender": self.gender, "birthday": birthday]
                self.userModel.updateProfileImage(#imageLiteral(resourceName: "default-user"), self.userData["uid"]!)
            })
        }
        else {
            self.registerIndicator?.stopAnimating()
            showAlertDialog(title: "회원가입 오류", message: "비밀번호가 일치하지 않습니다")
        }
    }
    
    func didComplete(_ profileImage: UIImage) {
        userModel.register(self.userData, UIImageJPEGRepresentation(profileImage, 0.1)!)
    }
    
    func didSuccess(_ userData: [String: String], _ profileData: Data) {
        FIRAuth.auth()?.signIn(withEmail: userData["email"]!, password: userData["password"]!, completion: { (user: FIRUser?, error) in
            if error != nil {
                print(error ?? "")
                return
            }
            self.registerIndicator?.stopAnimating()
            self.moveMainVC()
        })
    }
    
    func moveMainVC() {
        UserDefaults.standard.removeObject(forKey: "register")
        UserDefaults.standard.set(self.userData["uid"]!, forKey: "lastUid")
        
        let mainViewController = self.storyboard?.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = mainViewController
    }

    func setGender() {
        if genderTagTextField.text == "1" {
            gender = "male"
        }
        else if genderTagTextField.text == "2" {
            gender = "female"
        }
    }
    
    func showAlertDialog(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "Close Alert", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        
        self.present(alertController, animated: true, completion: nil)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if nameTextField.isEditing {
            birthdayTextField.becomeFirstResponder()
        }
        else if birthdayTextField.isEditing {
            genderTagTextField.becomeFirstResponder()
        }
        else if genderTagTextField.isEditing {
            emailTextField.becomeFirstResponder()
        }
        else if emailTextField.isEditing {
            passwordTextField.becomeFirstResponder()
        }
        else if passwordTextField.isEditing {
            telTextField.becomeFirstResponder()
        }
        else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

}
