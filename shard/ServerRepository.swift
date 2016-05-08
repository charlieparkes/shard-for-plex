/*
 Shard by Charlie Mathews & Sarah Burgess
 This work is licensed under a Creative Commons Attribution-NonCommercial 4.0 International License
 */

//https://www.trevisrothwell.com/2016/01/nsxmlparserdelegate-in-swift-2-0/

import Foundation

final class ServerRepository : NSObject, SelfPopulatingRepository {
    
    static var sharedInstance : ServerRepository = ServerRepository()
    var observersLoaded : Bool = false
    
    var queryInProgress = false
    dynamic var foundResults = false
    dynamic var selectedServer = 0
    var results : [Server] = []
    var parser : NSXMLParser = NSXMLParser()
    
    private override init() {
        super.init()
        
        loadObservers()
    }
    
    func clear() {
        removeObservers()
        results = []
        parser = NSXMLParser()
        foundResults = false
        queryInProgress = false
    }
    
    func loadObservers() {
        if(observersLoaded == false) {
            observersLoaded = true
            user.addObserver(self, forKeyPath: "loggedin", options: Constants.KVO_Options, context: nil)
        }
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        //print("ServerRepository: I sense that value of \(keyPath) changed to \(change![NSKeyValueChangeNewKey]!)")
        
        if keyPath == "loggedin" && user.loggedin == true && user.loginerror == false {
            
            // automatically pull servers when user logs in
            get()
        }
    }
    
    func removeObservers() {
        if(observersLoaded == true) {
            observersLoaded = false
            user.removeObserver(self, forKeyPath: "loggedin", context: nil)
        }
    }
    
    deinit {
        removeObservers()
    }
    
    func get() {
        
        if(user.loggedin == false || user.authentication_token == "") {
            print("Tried to get servers, but user not logged in.")
            return
        }
        
        foundResults = false
        queryInProgress = true
        
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        
        config.HTTPAdditionalHeaders = ["X-Plex-Token" : user.authentication_token,
                                        "X-Plex-Platform" : "iOS",
                                        "X-Plex-Platform-Version" : Constants.systemVersion,
                                        "X-Plex-Device" : Constants.model,
                                        "X-Plex-Device-Name" : Constants.name,
                                        "X-Plex-Client-Identifier" : Constants.uniqueID,
                                        "X-Plex-Product" : Constants.product,
                                        "X-Plex-Version" : Constants.version]
        
        //print(config.HTTPAdditionalHeaders)
        
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
        
        results = []
        parser = NSXMLParser(data: data)
        parser.delegate = self
        parser.parse()
        
    }
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        
        if elementName == "Server" {
            
            let server = Server()
            
            for (k,v) in attributeDict {
                
                if server.respondsToSelector(Selector(k)) && !NSObject.respondsToSelector(Selector(k)) {
                    server.setValue(v, forKey: k)
                }
            }
            
            print("Found \"\(server.name)\" at \(server.scheme)://\(server.address):\(server.port) - \(server.machineIdentifier)")
            results.append(server)
        }
    }
    
    func parserDidEndDocument(parser: NSXMLParser) {
        if results.count > 0 {
            foundResults = true
        }
        queryInProgress = false
    }
    
}