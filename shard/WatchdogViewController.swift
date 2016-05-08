//
//  RevealViewController.swift
//  shard
//
//  Created by Charles Mathews on 5/8/16.
//  Copyright © 2016 Charlie Mathews. All rights reserved.
//

import UIKit

class WatchdogViewController: UINavigationController {
    
    var loginInProgress : Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        servers.loadObservers()
        libraries.loadObservers()
        user.pullExistingUser()
        loadObservers()
        
        if user.loggedin == false {
            loginInProgress = true
            print("watchdog: user isn't logged in...")
            performSegueWithIdentifier("showLogin", sender: self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loadObservers() {
        user.addObserver(self, forKeyPath: "loggedin", options: Constants.KVO_Options, context: nil)
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        if keyPath == "loggedin" && user.loggedin == false && loginInProgress == false {
            
            print("watchdog: user logged out")
            loginInProgress = true
            performSegueWithIdentifier("showLogin", sender: self)
        } else if user.loggedin == true {
            loginInProgress = false
        }
        
    }
    
    deinit {
        user.removeObserver(self, forKeyPath: "loggedin", context: nil)
    }
    
    @IBAction func unwindFromLogin(segue:UIStoryboardSegue) {
        
        //
        
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
