//
//  MediaRepository.swift
//  shard
//
//  Created by Charles Mathews on 5/6/16.
//  Copyright © 2016 Charlie Mathews. All rights reserved.
//

/*
 Shard by Charlie Mathews & Sarah Burgess
 This work is licensed under a Creative Commons Attribution-NonCommercial 4.0 International License
 */

//https://forums.plex.tv/discussion/40688/retrieving-a-plex-media-servers-x-plex-token-using-the-myplex-api

import Foundation

class MediaRepository : NSObject, SelfPopulatingRepository {
    
    var observersLoaded : Bool = false
    var queryInProgress = false
    dynamic var foundResults = false
    var libraryIndex : Int = 0
    var parser : NSXMLParser = NSXMLParser()
    
    override init() {
        super.init()
        
        loadObservers()
    }
    
    func loadObservers() {
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        //print("ServerRepository: I sense that value of \(keyPath) changed to \(change![NSKeyValueChangeNewKey]!)")
        
        
    }
    
    deinit {
    }
    
    func get(server : Int, library : Int) {
        
        if(user.loggedin == false || user.authentication_token == "" || servers.results.count == 0 || libraries.results.count == 0) {
            print("Tried to get movies, but there were no servers to query.")
            return
        }
        
        foundResults = false
        queryInProgress = true
        libraryIndex = library
        
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        
        config.HTTPAdditionalHeaders = ["X-Plex-Token" : servers.results[server].accessToken,
                                        "X-Plex-Platform" : "iOS",
                                        "X-Plex-Platform-Version" : Constants.systemVersion,
                                        "X-Plex-Device" : Constants.model,
                                        "X-Plex-Device-Name" : Constants.name,
                                        "X-Plex-Client-Identifier" : Constants.uniqueID,
                                        "X-Plex-Product" : Constants.product,
                                        "X-Plex-Version" : Constants.version]
        
        //print(config.HTTPAdditionalHeaders)
        
        let session = NSURLSession(configuration: config, delegate: self, delegateQueue: nil)
        
        let url = "\(servers.results[server].getURL())\(Constants.WEB_API.sections)/\(libraries.results[library].key)/all"
        print("\n\(url)")
        
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        
        request.HTTPMethod = "GET"
        let task = session.downloadTaskWithRequest(request)
        task.resume()
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
            print("Processing response...", separator: "", terminator: "")
            self.processResponse(data)
        })
    }
    
    func processResponse(data : NSData) {
        print("as generic")
    }
    
    func count() -> Int {
        return 0
    }
}