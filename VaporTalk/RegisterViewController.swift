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

class RegisterViewController: UIViewController, UITextFieldDelegate {
    var isNearAgree: String = "true"
    var isCommerceAgree: String = "true"
    var isPasswordValid: Bool = false
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var telTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordCheckTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var nearAgreeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var commerceAgreeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var birthdayTextField: UITextField!
    @IBOutlet weak var sexTagTextField: UITextField!
    @IBOutlet weak var passwordCheckImgView: UIImageView!
    
    var sex: String = "male"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
    }
    
    func setUI() {
        registerButton.layer.cornerRadius = 5
        registerButton.layer.masksToBounds = true
        nameTextField.becomeFirstResponder()
    }
    
    @IBAction func nearAgreeValueChanged(_ sender: Any) {
        if nearAgreeSegmentedControl.selectedSegmentIndex == 1 {
            isNearAgree = "true"
        }
        else {
            isNearAgree = "false"
        }
    }
    
    @IBAction func commerceAgreeValueChanged(_ sender: Any) {
        if commerceAgreeSegmentedControl.selectedSegmentIndex == 1 {
            isCommerceAgree = "true"
        }
        else {
            isCommerceAgree = "false"
        }
    }
    
    @IBAction func birthdayEditingChanged(_ sender: Any) {
        if birthdayTextField.text!.characters.count == 6 {
            if sexTagTextField.text!.characters.count != 1 {
                sexTagTextField.becomeFirstResponder()
            }
            else {
                emailTextField.becomeFirstResponder()
            }
        }
    }
    
    @IBAction func sexTagEditingChanged(_ sender: Any) {
        if sexTagTextField.text == "1" || sexTagTextField.text == "2" {
            if sexTagTextField.text!.characters.count == 1 {
                emailTextField.becomeFirstResponder()
            }
        }
        else {
            sexTagTextField.text = ""
        }
    }

    @IBAction func passwordCheckEditingChanged(_ sender: Any) {
        passwordCheckImgView.isHidden = false
        let currentPassword: String = passwordTextField.text!
        if passwordCheckTextField.text == currentPassword {
            passwordCheckImgView.image = #imageLiteral(resourceName: "checked.png")
            isPasswordValid = true
        }
        else {
            passwordCheckImgView.image = #imageLiteral(resourceName: "clear-button")
            isPasswordValid = false
        }
    }
    
    @IBAction func registerButtonTouched(_ sender: Any) {
        self.view.endEditing(true)
        guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text, let tel = telTextField.text else {
            showAlertDialog(title: "Register Alert", message: "입력 정보를 모두 입력해주세요")
            return
        }
        
        if sexTagTextField.text == "1" {
            sex = "male"
        }
        else if sexTagTextField.text == "2" {
            sex = "female"
        }
        
        if isPasswordValid {
            FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user: FIRUser?, error) in
                if error != nil {
                    print(error ?? "")
                    return
                }
            
                let defaultProfileImage: String = "https://firebasestorage.googleapis.com/v0/b/vaportalk-6725e.appspot.com/o/user.png?alt=media&token=e3dc1040-654e-4f73-9003-8313ddc42e1a"
                
                let ref = FIRDatabase.database().reference()
                let userReference = ref.child("users").child((user?.uid)!)
                let values = ["name": name, "email": email, "tel": tel, "sex": self.sex, "birthday": self.birthdayTextField.text!, "profileImage": defaultProfileImage, "isNearAgree": self.isNearAgree, "isCommerceAgree": self.isCommerceAgree]
                
                let lastVaporReference = ref.child("lastMessages").child((user?.uid)!)
                let lastVaporValues = ["from": ""]
                lastVaporReference.setValue(lastVaporValues)
                
                userReference.updateChildValues(values, withCompletionBlock: { (error, ref) in
                    if error != nil {
                        print(error ?? "")
                        return
                    }
                    FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user: FIRUser?, error) in
                        if error != nil {
                            print(error ?? "")
                            return
                        }
                    })

                })
            })
        }
        else {
            showAlertDialog(title: "Register Alert", message: "비밀번호가 일치하지 않습니다")
        }
    }
    
    func showAlertDialog(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "Close Alert", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        
        self.present(alertController, animated: true, completion: nil)
    }

    @IBAction func backButtonTouched(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if nameTextField.isEditing {
            birthdayTextField.becomeFirstResponder()
        }
        else if birthdayTextField.isEditing {
            sexTagTextField.becomeFirstResponder()
        }
        else if sexTagTextField.isEditing {
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
