//
//  LoginViewController.swift
//  shard
//
//  Created by Charles Mathews on 4/19/16.
//  Copyright © 2016 Charlie Mathews. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    //User(u: "luxprimus",p: "Puppies&$w33t$")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        User.sharedInstance.login("luxprimus", p: "Puppies&$w33t$")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
