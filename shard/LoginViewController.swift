/*
 Shard by Charlie Mathews & Sarah Burgess
 This work is licensed under a Creative Commons Attribution-NonCommercial 4.0 International License
 */

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBAction func usernameFieldTouch(sender: AnyObject) {
    }
    
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameField.delegate = self
        passwordField.delegate = self
        
        //usernameField.placeholder="username"
        //passwordField.placeholder="password"
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func login(u: String, p: String) {
        //User.sharedInstance.login("luxprimus", p: "Puppies&$w33t$")
        
        if(u != "" && p != "") { // more extensive validation needed before publishing app
            User.sharedInstance.login(u, p: p)
        }
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == usernameField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            login(usernameField.text!, p: passwordField.text!)
        }
        return true
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
