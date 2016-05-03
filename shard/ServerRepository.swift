/*
 Shard by Charlie Mathews & Sarah Burgess
 This work is licensed under a Creative Commons Attribution-NonCommercial 4.0 International License
 */

//https://www.trevisrothwell.com/2016/01/nsxmlparserdelegate-in-swift-2-0/

import Foundation

final class ServerRepository : NSObject, NSURLSessionDelegate, NSURLSessionDownloadDelegate {
    
    static var sharedInstance : ServerRepository = ServerRepository()
    
    var servers : [Server] = []
    
    private override init() {
        super.init()
        
        print("server repository initialized")
        loadObservers()
    }
    
    func loadObservers() {
        user.addObserver(self, forKeyPath: "loggedin", options: Constants.KVO_Options, context: nil)
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        //print("ServerRepository: I sense that value of \(keyPath) changed to \(change![NSKeyValueChangeNewKey]!)")
        
        if keyPath == "loggedin" && user.loggedin == true && user.loginerror == false {
            
            // automatically pull servers when user logs in
            print("DEBUG: server repository sees that user logged in")
            get()
            
        }
        
    }
    
    deinit {
        user.removeObserver(self, forKeyPath: "loggedin", context: nil)
    }
    
    func get() {
        
        if(user.loggedin == false || user.authentication_token == "") {
            print("Tried to get servers, but user not logged in.")
            return
        }
        
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        
        print("Attempting to pull servers.")
        
        config.HTTPAdditionalHeaders = ["X-Plex-Token" : user.authentication_token,
                                        "X-Plex-Platform" : "iOS",
                                        "X-Plex-Platform-Version" : Constants.systemVersion,
                                        "X-Plex-Device" : Constants.model,
                                        "X-Plex-Device-Name" : Constants.name,
                                        "X-Plex-Client-Identifier" : Constants.uniqueID,
                                        "X-Plex-Product" : Constants.product,
                                        "X-Plex-Version" : Constants.version]
        
        print(config.HTTPAdditionalHeaders)
        
        let session = NSURLSession(configuration: config, delegate: self, delegateQueue: nil)
        
        let request = NSMutableURLRequest(URL: NSURL(string: Constants.PLEX_API.servers)!)
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
            self.processResponse(data)
        })
    }
    
    func processResponse(data : NSData) {
        
        print("DEBUG: servers request finished, need to parse xml")
        // todo: parse xml
        
    }

    
}