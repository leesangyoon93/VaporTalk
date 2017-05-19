//
//  AdditionalDataViewController.swift
//  VaporTalk
//
//  Created by 이상윤 on 2017. 4. 4..
//  Copyright © 2017년 이상윤. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FirebaseAuth
import FirebaseDatabase
import GoogleSignIn

class AdditionalDataViewController: UIViewController, UITextViewDelegate {

    var accessTokenString: String? = nil
    var sex: String = "male"
    var isNearAgree: String = "true"
    var isCommerceAgree: String = "true"
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var telTextField: UITextField!
    @IBOutlet weak var sexSegmentedControl: UISegmentedControl!
    @IBOutlet weak var nearAgreeSegmentControl: UISegmentedControl!
    @IBOutlet weak var commerceAgreeSegmentControl: UISegmentedControl!
    
    let user = FIRAuth.auth()?.currentUser
    
    override func viewWillAppear(_ animated: Bool) {
        let ref = FIRDatabase.database().reference()
        let userReference = ref.child("users").child((user?.uid)!).child("tel")
        userReference.observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
            print(snapshot)
            /*if let dictionary = snapshot.value as? [String: AnyObject] {
                if dictionary["tel"] == nil {
                    return
                }
                else {
                    let mainViewController = self.storyboard?.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.window?.rootViewController = mainViewController
                }
            }*/
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func setUI() {
        startButton.layer.cornerRadius = 5
        startButton.layer.masksToBounds = true
        nameTextField.becomeFirstResponder()
    }
    
    @IBAction func startButtonTouched(_ sender: Any) {
        self.view.endEditing(true)
        
        guard let name = nameTextField.text, let tel = telTextField.text else {
            showAlertDialog(title: "Register Alert", message: "입력 정보를 모두 입력해주세요")
            return
        }
        
        let ref = FIRDatabase.database().reference()
        let userReference = ref.child("users").child((user?.uid)!)
        
        let values = [
            "name": name, "email": user?.email! as Any,
            "profileImage": user?.photoURL?.absoluteString ?? "https://firebasestorage.googleapis.com/v0/b/vaportalk-6725e.appspot.com/o/default-user.png?alt=media&token=e3dc1040-654e-4f73-9003-8313ddc42e1a",
            "tel": tel,
            "sex": self.sex,
            "isNearAgree": self.isNearAgree,
            "isCommerceAgree": self.isCommerceAgree] as [String : Any]
        userReference.updateChildValues(values, withCompletionBlock: { (error, ref) in
            if error != nil {
                print(error ?? "")
                return
            }
            let mainViewController = self.storyboard?.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = mainViewController
        })
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if nameTextField.isEditing {
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

    @IBAction func sexValueChanged(_ sender: Any) {
        if sexSegmentedControl.selectedSegmentIndex == 0 {
            sex = "male"
        }
        else {
            sex = "female"
        }
    }
    @IBAction func nearAgreeValueChanged(_ sender: Any) {
        if nearAgreeSegmentControl.selectedSegmentIndex == 1 {
            isNearAgree = "true"
        }
        else {
            isNearAgree = "false"
        }
    }
    
    @IBAction func commerceAgreeValueChanged(_ sender: Any) {
        if commerceAgreeSegmentControl.selectedSegmentIndex == 1 {
            isCommerceAgree = "true"
        }
        else {
            isCommerceAgree = "false"
        }
    }
    
    @IBAction func backButtonTouched(_ sender: Any) {
        do {
            try
                FIRAuth.auth()!.signOut()
            FBSDKLoginManager().logOut()
            GIDSignIn.sharedInstance().signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func showAlertDialog(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "Close Alert", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        
        self.present(alertController, animated: true, completion: nil)
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
