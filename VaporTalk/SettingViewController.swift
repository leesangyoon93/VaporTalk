//
//  SettingViewController.swift
//  VaporTalk
//
//  Created by 이상윤 on 2017. 4. 1..
//  Copyright © 2017년 이상윤. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import FBSDKLoginKit

class SettingViewController: UIViewController {
    @IBOutlet weak var locationAgreeSwitch: UISwitch!
    @IBOutlet weak var pushAgreeSwitch: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
    }
    
    func setUI() {
        self.navigationItem.title = "설정"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "로그아웃", style: .plain, target: self, action: #selector(logoutButtonTouched))
    }

    @IBAction func locationAgreeSwitchChanged(_ sender: Any) {
        let user = UserDefaults.standard
        var isLocationAgree = "true"
        if !locationAgreeSwitch.isOn {
            isLocationAgree = "false"
            resetUserLocation()
        }
        user.set(isLocationAgree, forKey: "isLocationAgree")
        
        updateLocationAgree(isLocationAgree)
    }
    
    func resetUserLocation() {
        let ref = FIRDatabase.database().reference()
        let userLocationRef = ref.child("locations").child(UserDefaults.standard.object(forKey: "uid") as! String)
        let locationValues = ["latitude": 0, "longtitude": 0]
        userLocationRef.updateChildValues(locationValues)
    }
    
    func updateLocationAgree(_ isAgree: String) {
        let ref = FIRDatabase.database().reference()
        let userRef = ref.child("users").child(UserDefaults.standard.object(forKey: "uid") as! String)
        userRef.updateChildValues(["isLocationAgree": isAgree])
    }
    
    @IBAction func pushAgreeSwitchChanged(_ sender: Any) {
        let user = UserDefaults.standard
        var isPushAgree = "true"
        if !pushAgreeSwitch.isOn {
            isPushAgree = "false"
            resetFCM()
        }
        user.set(isPushAgree, forKey: "isPushAgree")
        
        updatePushAgree(isPushAgree)
    }
    
    func resetFCM() {
        let ref = FIRDatabase.database().reference()
        let userRef = ref.child("users").child(UserDefaults.standard.object(forKey: "uid") as! String)
        userRef.updateChildValues(["fcm": ""])
    }
    
    func updatePushAgree(_ isAgree: String) {
        let ref = FIRDatabase.database().reference()
        let userRef = ref.child("users").child(UserDefaults.standard.object(forKey: "uid") as! String)
        userRef.updateChildValues(["isPushAgree": isAgree])
    }
    
    func logoutButtonTouched() {
        showLogoutDialog(title: "로그아웃", message: "로그아웃 하시겠습니까?")
    }
    
    func showLogoutDialog(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        let logoutAction = UIAlertAction(title: "확인", style: .default) { (_) in
            let ref = FIRDatabase.database().reference()
            let userRef = ref.child("users").child((FIRAuth.auth()?.currentUser?.uid)!)
            userRef.updateChildValues(["fcm": ""])
            
            do {
                try
                    FIRAuth.auth()!.signOut()
                FBSDKLoginManager().logOut()
                GIDSignIn.sharedInstance().signOut()
                
                let appDomain = Bundle.main.bundleIdentifier
                UserDefaults.standard.removePersistentDomain(forName: appDomain!)
                
                let indexVC = self.storyboard?.instantiateViewController(withIdentifier: "IndexViewController") as! IndexViewController
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window?.rootViewController = indexVC
                
            } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
            }

        }
        alertController.addAction(cancelAction)
        alertController.addAction(logoutAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
}
