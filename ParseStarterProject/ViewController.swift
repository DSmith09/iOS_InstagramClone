/**
* Copyright (c) 2015-present, Parse, LLC.
* All rights reserved.
*
* This source code is licensed under the BSD-style license found in the
* LICENSE file in the root directory of this source tree. An additional grant
* of patent rights can be found in the PATENTS file in the same directory.
*/

import UIKit
// Parse Library for Access to PFUser/PFObject etc.
import Parse

// Generic Login/SignUp Page -> Can be utilized within other apps
class ViewController: UIViewController {
    // Constants
    private static let SIGN_UP = "Sign Up"
    private static let LOGIN = "Login"
    private static let SIGN_UP_MESSAGE = "Don't Already Have An Account? ->"
    private static let LOGIN_MESSAGE = "Already Have An Account? ->"
    private static let ALERT_ACTION_OK = "OK"
    private static let SNR = "System Not Responding"
    private static let USER_TABLE_SEGUE = "showUserTable"
    
    // Default Error Message
    private var errorMessage = "Please Try Again"
    
    // Boolean Switch
    private var signUpMode = true
    
    // View Variables
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpOrLoginText: UIButton!
    @IBOutlet weak var changeViewLabelsText: UIButton!
    @IBOutlet weak var messageText: UILabel!
    
    // Spinner Variable
    private var activityIndicator = UIActivityIndicatorView()
    
    @IBAction func signUpOrLoginButton(_ sender: AnyObject) {
        if validateFormEntries() {
            // Show Spinner on Screen
            pauseScreen()
            let user = createUserObject()
            if signUpMode {
                // If Signing In for First Time, Add User to Parse Table
                createNewUser(user: user)
            } else {
                loginWithUser(user: user)
            }
        }
    }
    
    @IBAction func changeViewLabelsButton(_ sender: AnyObject) {
        if signUpMode {
            // Change to Sign Up View
            changeViewLabels(signUpButtonText: ViewController.LOGIN, changeViewText: ViewController.SIGN_UP, messageText: ViewController.SIGN_UP_MESSAGE)
        } else {
            changeViewLabels(signUpButtonText: ViewController.SIGN_UP, changeViewText: ViewController.LOGIN, messageText: ViewController.LOGIN_MESSAGE)
        }
        signUpMode = !signUpMode
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if PFUser.current() != nil {
            performSegue(withIdentifier: ViewController.USER_TABLE_SEGUE, sender: self)
        }
        self.navigationController?.navigationBar.isHidden = true
    }
    
    // Utility Methods
    private func validateFormEntries() -> Bool {
        if emailTextField.text == "" || passwordTextField.text == "" {
            self.createAlert(title: "Missing Email/Password", message: "Please Enter Both A Valid Email And Password")
            return false
        }
        return true
    }
    
    private func createAlert(title: String, message: String) -> Void {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: ViewController.ALERT_ACTION_OK, style: .default, handler: {
            (action) in
                alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func createUserObject() -> PFUser {
        let user = PFUser()
        user.username = emailTextField.text
        user.email = emailTextField.text
        user.password = passwordTextField.text
        return user
    }
    
    private func changeViewLabels(signUpButtonText: String, changeViewText: String, messageText: String) -> Void {
        signUpOrLoginText.setTitle(signUpButtonText, for: [])
        changeViewLabelsText.setTitle(changeViewText, for: [])
        self.messageText.text = messageText
    }
    
    private func pauseScreen() -> Void {
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        self.view.addSubview(activityIndicator)
        self.activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    private func createNewUser(user: PFUser) -> Void {
        user.signUpInBackground(block: {
            (success, error) in self.unwrapSignupLoginResult(success: success, error: error)
        })
    }
    
    private func loginWithUser(user: PFUser) -> Void {
        PFUser.logInWithUsername(inBackground: user.email!, password: user.password!, block: {
            (success, error) in self.unwrapSignupLoginResult(success: success as Any, error: error)
        })
    }
    
    private func unwrapSignupLoginResult(success: Any, error: Error?) -> Void {
        self.activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
        if (error != nil) {
            print(error!)
            
            if let error = error as? NSError {
                errorMessage = (error.userInfo["error"] as? String)!
            }
            self.createAlert(title: ViewController.SNR, message: errorMessage)
        } else {
            if signUpMode {
                print("User Created")
                performSegue(withIdentifier: ViewController.USER_TABLE_SEGUE, sender: self)
            } else {
                print("User Logged In")
                performSegue(withIdentifier: ViewController.USER_TABLE_SEGUE, sender: self)
            }
        }
    }
}
