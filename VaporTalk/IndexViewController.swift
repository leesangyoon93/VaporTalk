//
//  IndexViewController.swift
//  VaporTalk
//
//  Created by 이상윤 on 2017. 3. 30..
//  Copyright © 2017년 이상윤. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import FBSDKLoginKit

class IndexViewController: UIViewController, FBSDKLoginButtonDelegate, GIDSignInUIDelegate, UITextFieldDelegate, GIDSignInDelegate {
    
    var accessTokenString: String? = nil
    @IBOutlet weak var googleLoginButton: GIDSignInButton!
    @IBOutlet weak var facebookLoginButton: FBSDKLoginButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var generalLoginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }
    
    func setUI() {
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        facebookLoginButton.delegate = self
        facebookLoginButton.readPermissions = ["public_profile", "email"]
        
        emailTextField.layer.cornerRadius = 5
        emailTextField.layer.masksToBounds = true
        passwordTextField.layer.cornerRadius = 5
        passwordTextField.layer.masksToBounds = true
        generalLoginButton.layer.cornerRadius = 5
        generalLoginButton.layer.masksToBounds = true
    }

    // Facebook Logout
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
    }
    
    @IBAction func generalLogin(_ sender: Any) {
        FIRAuth.auth()?.signIn(withEmail: emailTextField.text!, password: passwordTextField.text!, completion: { (user: FIRUser?, error) in
            if error != nil {
                self.showAlertDialog(title: "Login Alert", message: "이메일 또는 비밀번호가 틀렸습니다")
                return
            }
        })
    }
    
    // Facebook Login
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil {
            showAlertDialog(title: "Login Alert", message: "이메일 또는 비밀번호가 틀렸습니다")
            return
        }
        
        let accessToken = FBSDKAccessToken.current()
        self.accessTokenString = accessToken?.tokenString
        
        let credentials = FIRFacebookAuthProvider.credential(withAccessToken: accessTokenString!)
        FIRAuth.auth()?.signIn(with: credentials, completion: { (user, error) in
            if error != nil {
                print("Something went wrong", error ?? "")
                return
            }
            self.performSegue(withIdentifier: "AdditionalDataSegue", sender: nil)
        })
    }
    
    // Google Login
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if (error) != nil {
            showAlertDialog(title: "Login Alert", message: "이메일 또는 비밀번호가 틀렸습니다")
            return
        }
        
        let authentication = user.authentication
        let credential = FIRGoogleAuthProvider.credential(withIDToken: (authentication?.idToken)!, accessToken: (authentication?.accessToken)!)
        
        FIRAuth.auth()?.signIn(with: credential, completion: { ( user, error) in
            if error != nil {
                return
            }
            self.performSegue(withIdentifier: "AdditionalDataSegue", sender: nil)
        })
    }

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if emailTextField.isEditing {
            passwordTextField.becomeFirstResponder()
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
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AdditionalDataSegue" {
            (segue.destination as! AdditionalDataViewController).accessTokenString = self.accessTokenString
        }
    }
 

}
