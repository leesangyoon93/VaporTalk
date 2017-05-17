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
    @IBOutlet weak var nearUserSwitch: UISwitch!
    @IBOutlet weak var timeCommerceSwitch: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func nearUserSwitchChanged(_ sender: Any) {
    }
    
    @IBAction func timeCommerceSwitchChanged(_ sender: Any) {
    }
    
    @IBAction func LogoutTouched(_ sender: Any) {
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
}
