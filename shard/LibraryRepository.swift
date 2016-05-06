/*
 Shard by Charlie Mathews & Sarah Burgess
 This work is licensed under a Creative Commons Attribution-NonCommercial 4.0 International License
 */

//https://forums.plex.tv/discussion/40688/retrieving-a-plex-media-servers-x-plex-token-using-the-myplex-api

import Foundation

class LibraryRepository : NSObject, SelfPopulatingRepository {
    
    static var sharedInstance : LibraryRepository = LibraryRepository()
    var observersLoaded : Bool = false
    
    var queryInProgress = false
    dynamic var foundResults = false
    var results : [Library] = []
    var parser : NSXMLParser = NSXMLParser()
    
    private override init() {
        super.init()
        
        loadObservers()
    }
    
    func loadObservers() {
        if(observersLoaded == false) {
            observersLoaded = true
            servers.addObserver(self, forKeyPath: "foundResults", options: Constants.KVO_Options, context: nil)
            servers.addObserver(self, forKeyPath: "selectedServer", options: Constants.KVO_Options, context: nil)
        }
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        //print("ServerRepository: I sense that value of \(keyPath) changed to \(change![NSKeyValueChangeNewKey]!)")
        
        if keyPath == "foundResults" && servers.foundResults == true && servers.results.count > 0 {
            get(servers.selectedServer) // update to reflect selected server
        } else if keyPath == "selectedServer" {
            get(servers.selectedServer)
        }
    
    }
    
    deinit {
        servers.removeObserver(self, forKeyPath: "foundResults", context: nil)
        servers.removeObserver(self, forKeyPath: "selectedServer", context: nil)
    }
    
    func get(index : Int) {
        
        if(user.loggedin == false || user.authentication_token == "" || servers.results.count == 0) {
            print("Tried to get libraries, but there were no servers to query.")
            return
        }
        
        foundResults = false
        queryInProgress = true
        
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        
        config.HTTPAdditionalHeaders = ["X-Plex-Token" : servers.results[index].accessToken,
                                        "X-Plex-Platform" : "iOS",
                                        "X-Plex-Platform-Version" : Constants.systemVersion,
                                        "X-Plex-Device" : Constants.model,
                                        "X-Plex-Device-Name" : Constants.name,
                                        "X-Plex-Client-Identifier" : Constants.uniqueID,
                                        "X-Plex-Product" : Constants.product,
                                        "X-Plex-Version" : Constants.version]
        
        //print(config.HTTPAdditionalHeaders)
        
        let session = NSURLSession(configuration: config, delegate: self, delegateQueue: nil)
        
        let request = NSMutableURLRequest(URL: NSURL(string: "\(servers.results[index].getURL())\(Constants.WEB_API.sections)")!)
        //let request = NSMutableURLRequest(URL: NSURL(string: "\(Constants.PLEX_API.sections)")!)
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
        
        if elementName == "Directory" {
            
            let library = Library()
            
            for (k,v) in attributeDict {
                
                if library.respondsToSelector(Selector(k)) && !NSObject.respondsToSelector(Selector(k)) {
                    library.setValue(v, forKey: k)
                }
            }
            
            results.append(library)
        }
    }
    
    func parserDidEndDocument(parser: NSXMLParser) {
        if results.count > 0 {
            print("Found \(results.count) libraries.")
            
            for library in results {
                print("\t\(library.title)")
            }
            
            foundResults = true
        }
        queryInProgress = false
    }
    
}