/*
 Shard by Charlie Mathews & Sarah Burgess
 This work is licensed under a Creative Commons Attribution-NonCommercial 4.0 International License
*/

//https://forums.plex.tv/discussion/129922/how-to-request-a-x-plex-token-token-for-your-app
//https://github.com/Arcanemagus/plex-api

import Foundation

final class User : NSObject, NSURLSessionDelegate, NSURLSessionDownloadDelegate {
    
    static var sharedInstance : User = User()
    
    let defaults : NSUserDefaults = NSUserDefaults() //NSUserDefaults.standardUserDefaults()
    let defaults_token_key : String = Constants.Defaults.token_key
    //let defaults_username_key : String = "shard_username"
    
    dynamic var loggedin : Bool = false
    dynamic var loginerror : Bool = false
    var loginerrormessage : String = ""
    
    dynamic var username = ""
    dynamic var token = ""
    
    dynamic var authentication_token : String {
        get {
            return token
        }
        set {
            print("Set token \"\(newValue)\"")
            token = newValue
            loggedin = checkLogin()
            defaults.setObject(newValue, forKey: defaults_token_key)
        }
    }
    
    private override init () {
        
        super.init()
        authentication_token = "" // FOR DEBUG
    }
    
    func pullExistingUser() {
        if let t : String = defaults.stringForKey(defaults_token_key) {
            if t != "" {
                print("We have a stored user token.")
                authentication_token = t
            }
        }
    }
    
    func checkLogin() -> Bool {
        // if authentication_token is valid... (query plex)
        print("DEBUG: need to verify stored token!")
        return true
    }
    
    func loginRequest(u : String, p : String) {
        
        loggedin = false
        loginerror = false
        
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        
        let userPasswordString = "\(u):\(p)"
        let userPasswordData = userPasswordString.dataUsingEncoding(NSUTF8StringEncoding)
        let base64EncodedCredential = userPasswordData!.base64EncodedStringWithOptions([])
        let authString = "Basic \(base64EncodedCredential)"
        
        print("Attempting login. \"\(authString)\"")
        
        config.HTTPAdditionalHeaders = ["Authorization" : authString,
                                        "X-Plex-Platform" : "iOS",
                                        "X-Plex-Platform-Version" : Constants.systemVersion,
                                        "X-Plex-Device" : Constants.model,
                                        "X-Plex-Device-Name" : Constants.name,
                                        "X-Plex-Client-Identifier" : Constants.uniqueID,
                                        "X-Plex-Product" : Constants.product,
                                        "X-Plex-Version" : Constants.version]
        
        //print(config.HTTPAdditionalHeaders)
        
        let session = NSURLSession(configuration: config, delegate: self, delegateQueue: nil)
        
        let request = NSMutableURLRequest(URL: NSURL(string: Constants.PLEX_API.signin)!)
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
            loginerror = true
            loginerrormessage = "Unknown error."
            print("Login request session error.")
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
                    loginerrormessage = msg
                    loginerror = true
                }
            }
            
            //print(jsonData)
            
        } catch {
            NSLog("JSON serialization failed!")
        }
    }
}