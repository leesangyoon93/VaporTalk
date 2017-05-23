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
import NVActivityIndicatorView

class IndexViewController: UIViewController, FBSDKLoginButtonDelegate, GIDSignInUIDelegate, UITextFieldDelegate, GIDSignInDelegate {
    
    @IBOutlet weak var googleLoginButton: GIDSignInButton!
    @IBOutlet weak var facebookLoginButton: FBSDKLoginButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var generalLoginButton: UIButton!
    
    var loginIndicator: NVActivityIndicatorView?
    var token: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        facebookLoginButton.delegate = self
        setUI()
    }
    
    func setUI() {
        facebookLoginButton.readPermissions = ["email"]
        
        emailTextField.layer.cornerRadius = 5
        emailTextField.layer.masksToBounds = true
        passwordTextField.layer.cornerRadius = 5
        passwordTextField.layer.masksToBounds = true
        generalLoginButton.layer.cornerRadius = 5
        generalLoginButton.layer.masksToBounds = true
        
        let frame = CGRect(x: self.view.frame.width / 2 - 37.5, y: self.view.frame.height / 2 - 37.5, width: 75, height: 75)
        loginIndicator = NVActivityIndicatorView(frame: frame, type: NVActivityIndicatorType.ballSpinFadeLoader, color: UIColor.blue, padding: 20)
        self.view.addSubview(loginIndicator!)
    }

    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
    }
    
    @IBAction func generalLogin(_ sender: Any) {
        loginIndicator?.startAnimating()
        FIRAuth.auth()?.signIn(withEmail: emailTextField.text!, password: passwordTextField.text!, completion: { (user: FIRUser?, error) in
            self.loginIndicator?.stopAnimating()
            if error != nil {
                self.showAlertDialog(title: "Login Alert", message: "이메일 또는 비밀번호가 틀렸습니다")
                return
            }
        })
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil {
            return
        }
        token = result.token.userID
        let credentials = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        checkSocialLogin(credentials)
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if (error) != nil {
            return
        }
        let authentication = user.authentication
        token = (authentication?.clientID)!
        let credentials = FIRGoogleAuthProvider.credential(withIDToken: (authentication?.idToken)!, accessToken: (authentication?.accessToken)!)
        checkSocialLogin(credentials)
    }

    func checkSocialLogin(_ credentials: FIRAuthCredential) {
        loginIndicator?.startAnimating()
        let ref = FIRDatabase.database().reference()
        let socialRef = ref.child("social")
        socialRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let dic = snapshot.value as? [String: String] {
                let isSocialUser = dic.values.contains(self.token)
                if isSocialUser {
                    FIRAuth.auth()?.signIn(with: credentials, completion: { (user, error) in
                        self.loginIndicator?.stopAnimating()
                    })
                }
                else {
                    self.loginIndicator?.stopAnimating()
                    self.performSegue(withIdentifier: "AdditionalDataSegue", sender: credentials)
                }
            }
            else {
                self.loginIndicator?.stopAnimating()
                self.performSegue(withIdentifier: "AdditionalDataSegue", sender: credentials)
            }
        }) { (error) in
            self.loginIndicator?.stopAnimating()
        }
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AdditionalDataSegue" {
            let additionalDataVC = (segue.destination as! UINavigationController).viewControllers.first as! AdditionalDataViewController
            additionalDataVC.credentials = sender as? FIRAuthCredential
            additionalDataVC.token = token
        }
    }
 

}
