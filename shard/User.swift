//
//  User.swift
//  shard
//
//  Created by Charles Mathews on 4/19/16.
//  Copyright © 2016 Charlie Mathews. All rights reserved.
//

import Foundation

class User : NSObject, NSURLSessionDelegate, NSURLSessionDownloadDelegate {
    
    let PLEX_signin : String = "https://plex.tv/users/sign_in.json"
    
    let uuid : String       = NSUUID().UUIDString
    let product : String    = "Shard for iOS"
    let version : String    = "0.1"
    
    dynamic var token : String
    
    override init () {
        token = ""
    }
    
    init(t : String) {
        token = t
    }
    
    init(u : String, p : String) {
        token = ""
        
        super.init()
        
        login(u, p: p)
    }
    
    func login(u : String, p : String) {
        
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        
        let userPasswordString = "\(u):\(p)"
        let userPasswordData = userPasswordString.dataUsingEncoding(NSUTF8StringEncoding)
        let base64EncodedCredential = userPasswordData!.base64EncodedStringWithOptions([])
        let authString = "Basic \(base64EncodedCredential)"
        
        print("Attempting login. \"\(authString)\"")
        
        config.HTTPAdditionalHeaders = ["Authorization" : authString,
                                        "X-Plex-Client-Identifier" : uuid,
                                        "X-Plex-Product" : product,
                                        "X-Plex-Version" : version]
        let session = NSURLSession(configuration: config, delegate: self, delegateQueue: nil)
        let task = session.downloadTaskWithURL(NSURL(string: PLEX_signin)!)
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
        print(data)
    }
}