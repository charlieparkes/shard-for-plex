//
//  User.swift
//  shard
//
//  Created by Charles Mathews on 4/19/16.
//  Copyright © 2016 Charlie Mathews. All rights reserved.
//

import UIKit
import Foundation

class User : NSObject, NSURLSessionDelegate, NSURLSessionDownloadDelegate {
    
    static var sharedInstance : User = User()
    
    let PLEX_signin : String = "https://plex.tv/users/sign_in.json"
    
    let product : String    = "Shard"
    let version : String    = "0.1"
    
    let defaults : NSUserDefaults = NSUserDefaults() //NSUserDefaults.standardUserDefaults()
    let defaults_token_key : String = "shard_token"
    let defaults_username_key : String = "shard_username"
    
    dynamic var loggedin : Bool
    dynamic var username = ""
    dynamic var token = ""
    dynamic var authentication_token : String {
        get {
            return token
        }
        set {
            print("Set token \(newValue)")
            token = newValue
            defaults.setObject(newValue, forKey: defaults_token_key)
        }
    }
    
    private override init () {
        loggedin = false
        
        super.init()
        
        if let t : String = defaults.stringForKey(defaults_token_key) {
            print("We have a stored user token.")
            authentication_token = t
        }
        if let u : String = defaults.stringForKey(defaults_username_key) {
            print("We have a stored username.")
            username = u
        }
    }
    
    func checkToken() {
        
    }
    
    func login(u : String, p : String) {
        loginRequest(u, p: p)
    }
    
    func loginRequest(u : String, p : String) {
        
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        
        let userPasswordString = "\(u):\(p)"
        let userPasswordData = userPasswordString.dataUsingEncoding(NSUTF8StringEncoding)
        let base64EncodedCredential = userPasswordData!.base64EncodedStringWithOptions([])
        let authString = "Basic \(base64EncodedCredential)"
        
        print("Attempting login. \"\(authString)\"")
        
        config.HTTPAdditionalHeaders = ["Authorization" : authString,
                                        "X-Plex-Platform" : "iOS",
                                        "X-Plex-Platform-Version" : UIDevice.currentDevice().systemVersion,
                                        "X-Plex-Device" : UIDevice.currentDevice().model,
                                        "X-Plex-Device-Name" : UIDevice.currentDevice().name,
                                        "X-Plex-Client-Identifier" : NSUUID().UUIDString,
                                        "X-Plex-Product" : product,
                                        "X-Plex-Version" : version]
        
        print(config.HTTPAdditionalHeaders)
        
        let session = NSURLSession(configuration: config, delegate: self, delegateQueue: nil)
        
        //let task = session.downloadTaskWithURL(NSURL(string: PLEX_signin)!)
        //task.resume()
        
        let request = NSMutableURLRequest(URL: NSURL(string: PLEX_signin)!)
        request.HTTPMethod = "POST"
        let task = session.downloadTaskWithRequest(request)
        task.resume()
    }
    
    // Download in progress.
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
    }
    
    // Download complete with error.
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        if(error != nil) {
            print(error)
        }
    }
    
    // Download complete.
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        
        let data = NSData(contentsOfURL: location)!
        NSOperationQueue.mainQueue().addOperationWithBlock({
            self.processResponse(data)
        })
    }
    
    func processResponse(data : NSData) {
        do {
            
            let jsonData = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as! Dictionary<String, AnyObject>
            
            for (k, v) in jsonData {
                if k == "user" {
                    
                    for (k,v) in jsonData["user"] as! Dictionary<String, AnyObject> {
                        
                        if self.respondsToSelector(Selector(k)) && !NSObject.respondsToSelector(Selector(k)) {
                            self.setValue(v, forKey: k)
                        }
                    }
                    
                } else if k == "error" {
                    let msg = v as! String
                    print(msg)
                }
            }
            
            print(jsonData)
            
        } catch {
            NSLog("JSON serialization failed!")
        }
    }
}