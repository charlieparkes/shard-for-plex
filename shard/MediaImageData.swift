//
//  MediaImageData.swift
//  shard
//
//  Created by Charles Mathews on 5/7/16.
//  Copyright © 2016 Charlie Mathews. All rights reserved.
//

import Foundation

class MediaImageData : NSObject, NSURLSessionDelegate, NSURLSessionDownloadDelegate {
    
    var task : NSURLSessionDownloadTask? = nil
    var data = NSData()
    dynamic var imageDownloadComplete : Bool = false
    var downloadInProgress : Bool = false
    var item = 0
    
    override init() {
        super.init()
    }
    
    init(i : Int) {
        super.init()
        item = i
    }
    
    func get(url : NSURL) {
        
        if(user.loggedin == false || user.authentication_token == "" || servers.results.count == 0) {
            print("Tried to get image, but there were no servers to query.")
            return
        }
        
        downloadInProgress = true
        
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        
        config.HTTPAdditionalHeaders = ["X-Plex-Token" : servers.results[servers.selectedServer].accessToken,
                                        "X-Plex-Platform" : "iOS",
                                        "X-Plex-Platform-Version" : Constants.systemVersion,
                                        "X-Plex-Device" : Constants.model,
                                        "X-Plex-Device-Name" : Constants.name,
                                        "X-Plex-Client-Identifier" : Constants.uniqueID,
                                        "X-Plex-Product" : Constants.product,
                                        "X-Plex-Version" : Constants.version]
        
        let session = NSURLSession(configuration: config, delegate: self, delegateQueue: nil)
        
        let request = NSMutableURLRequest(URL: url)
        
        request.HTTPMethod = "GET"
        task = session.downloadTaskWithRequest(request)
        task!.resume()
    }
    
    // Download in progress.
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
    }
    
    // Download complete with error.
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        if(error != nil) {
            print("DEBUG: download completed with error")
        }
    }
    
    // Download complete.
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        
        let data = NSData(contentsOfURL: location)!
        NSOperationQueue.mainQueue().addOperationWithBlock({
            self.processResponse(data)
        })
    }
    
    func processResponse(d : NSData) {
        
        data = d
        downloadInProgress = false
        imageDownloadComplete = true
    }
}