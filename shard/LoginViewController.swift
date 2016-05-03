/*
 Shard by Charlie Mathews & Sarah Burgess
 This work is licensed under a Creative Commons Attribution-NonCommercial 4.0 International License
 */

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var loginContainer: UIView!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var logoImage: UIImageView!
    
    @IBAction func usernameFieldTouch(sender: AnyObject) {
    }
    
    func filterChars(field: UITextField) {
        field.text = field.text?.stringByReplacingOccurrencesOfString(" ", withString: "")
    }
    
    @IBAction func usernameChanged(sender: AnyObject) {
        filterChars(sender as! UITextField)
    }
    
    @IBAction func passwordChanged(sender: AnyObject) {
        filterChars(sender as! UITextField)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameField.delegate = self
        passwordField.delegate = self
        
        loadObservers()
        servers.loadObservers()
        
        if let t : String = NSUserDefaults().stringForKey(Constants.Defaults.token_key) {
            if t != "" {
                //animateLogin(true)
                NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(self.animateLogin(_:)), userInfo: nil, repeats: false)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func login(u: String, p: String) {
        //User.sharedInstance.login("luxprimus", p: "Puppies&$w33t$")

        //validation is done on login screen
        user.login(u, p: p)
    }
    
    func isPasswordValid() -> Bool {
        
        if passwordField.text == "" {
            return false
        }
        
        return true
    }
    
    func isUsernameValid() -> Bool {
        
        if usernameField.text == "" {
            return false
        }
        
        return true
    }
    
    func animateLogo(enabled : Bool) {
        
        if enabled == true {
            UIView.animateWithDuration(0.3, delay: 0.0, options: [.CurveEaseOut, .Repeat, .Autoreverse], animations: {
                self.logoImage.alpha = 0.7
            }, completion: nil)
        } else if enabled == false {
            logoImage.layer.removeAllAnimations()
            
            UIView.animateWithDuration(0.3, delay: 0.0, options: [.CurveEaseOut], animations: {
                self.logoImage.alpha = 1
                }, completion: nil)
        }
    }
    
    func animateLogin(enabled : Bool) {
        
        if enabled == true {
            animateLoginProgress()
        } else if enabled == false {
            animateLoginRegress()
        } else {
            animateLoginProgress()
        }
        
    }
    
    func animateLoginProgress() {
        UIView.animateWithDuration(1, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            
            self.loginContainer.alpha = 0
            let distance = self.view.bounds.height - (self.loginContainer.center.y - (self.loginContainer.frame.height/2))
            print("moving login \(distance)")
            self.loginContainer.transform = CGAffineTransformTranslate(self.loginContainer.transform, 0, distance)
            
            }, completion: nil)
        
        UIView.animateWithDuration(2, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            
            let distance = self.view.center.y - self.logoImage.center.y
            print("moving login \(distance)")
            self.logoImage.transform = CGAffineTransformTranslate(self.logoImage.transform, 0, distance)
            
            }, completion: nil)
        
        animateLogo(true)
    }
    
    func animateLoginRegress() {
        animateLogo(false)
        self.usernameField.text = ""
        self.passwordField.text = ""
        
        UIView.animateWithDuration(1, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            
            self.loginContainer.alpha = 0.65
            self.loginContainer.transform = CGAffineTransformIdentity
            
            }, completion: nil)
        
        UIView.animateWithDuration(1, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            
            self.logoImage.transform = CGAffineTransformIdentity
            
            }, completion: nil)
        
        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(shakeLogin), userInfo: nil, repeats: false)
    }
    
    func shakeLogin() {
        shake(loginContainer)
    }
    
    func shake(field : UIView) {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.duration = 0.6
        animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0 ]
        field.layer.addAnimation(animation, forKey: "shake")
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == usernameField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            
            if(isPasswordValid() && isUsernameValid()) {
                
                animateLogin(true)
                login(usernameField.text!, p: passwordField.text!)
                
                //NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: #selector(animateLogin), userInfo: nil, repeats: false)
                
            } else {
                
                shakeLogin()
                self.usernameField.text = ""
                self.passwordField.text = ""
                
            }
        }
        return true
    }
    
    func loadObservers() {
        user.addObserver(self, forKeyPath: "loggedin", options: Constants.KVO_Options, context: nil)
        user.addObserver(self, forKeyPath: "loginerror", options: Constants.KVO_Options, context: nil)
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        //print("Login: I sense that value of \(keyPath) changed to \(change![NSKeyValueChangeNewKey]!)")
        
        if keyPath == "loggedin" && user.loggedin == true && user.loginerror == false {
            
            //segue to servers view
            
        } else if keyPath == "loginerror" && user.loginerror == true {
            
            animateLogin(false)
            
            let alert = UIAlertController(title: "Oops!", message: user.loginerrormessage, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default) { _ in })
            self.presentViewController(alert, animated: true){}
        }

    }

    deinit {
        user.removeObserver(self, forKeyPath: "loggedin", context: nil)
        user.removeObserver(self, forKeyPath: "loginerror", context: nil)
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
