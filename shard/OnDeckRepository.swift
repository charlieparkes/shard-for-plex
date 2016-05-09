/*
 Shard by Charlie Mathews & Sarah Burgess
 This work is licensed under a Creative Commons Attribution-NonCommercial 4.0 International License
 */

//https://www.trevisrothwell.com/2016/01/nsxmlparserdelegate-in-swift-2-0/

import Foundation

final class OnDeckRepository : NSObject, SelfPopulatingRepository {
    
    static var sharedInstance : OnDeckRepository = OnDeckRepository()
    var observersLoaded : Bool = false
    
    var queryInProgress = false
    dynamic var foundResults = false
    dynamic var selectedServer = 0
    var results : [Movie] = []
    var parser : NSXMLParser = NSXMLParser()
    
    override init() {
        super.init()
        
        loadObservers()
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
    
    deinit {
        user.removeObserver(self, forKeyPath: "loggedin", context: nil)
    }
    
    func get() {
        
        if(user.loggedin == false || user.authentication_token == "") {
            print("User not logged in.")
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
        
        
        let session = NSURLSession(configuration: config, delegate: self, delegateQueue: nil)
        
        let address = ServerRepository.sharedInstance.results[ServerRepository.sharedInstance.selectedServer].address
        let port = ServerRepository.sharedInstance.results[ServerRepository.sharedInstance.selectedServer].port
        
        //THIS RIGHT HERE is probably the only part of this that you'll really care about.
        let request = NSMutableURLRequest(URL: NSURL(string: "\(address):\(port)/library/onDeck")!)
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
        
        let movie = Movie()
        if elementName == "Movie" {
            for(k,val) in attributeDict {
                if movie.respondsToSelector(Selector(k)) && !NSObject.respondsToSelector(Selector(k)) {
                    movie.setValue(val, forKey: k)
                }
            }
        }
        print("Found \(movie.title)")
        results.append(movie)
    }
    
    func parserDidEndDocument(parser: NSXMLParser) {
        if results.count > 0 {
            foundResults = true
        }
        queryInProgress = false
    }
    
}