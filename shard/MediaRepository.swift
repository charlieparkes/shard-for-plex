/*
 Shard by Charlie Mathews & Sarah Burgess
 This work is licensed under a Creative Commons Attribution-NonCommercial 4.0 International License
 */

/*
 Shard by Charlie Mathews & Sarah Burgess
 This work is licensed under a Creative Commons Attribution-NonCommercial 4.0 International License
 */

//https://forums.plex.tv/discussion/40688/retrieving-a-plex-media-servers-x-plex-token-using-the-myplex-api

import Foundation

class MediaRepository : NSObject, SelfPopulatingRepository {
    
    static var sharedInstance : MediaRepository = MediaRepository()
    
    var observersLoaded : Bool = false
    var queryInProgress = false
    dynamic var foundResults = false
    var libraryIndex : Int = 0
    var parser : NSXMLParser = NSXMLParser()
    var results : [Media] = []
    var type : String = ""
    
    dynamic var deinitCanary = false
    
    private override init() {
        super.init()
        loadObservers()
    }
    
    func clear() {
        removeObservers()
        queryInProgress = false
        foundResults = false
        libraryIndex = 0
        parser = NSXMLParser()
        results = []
        type = ""
    }
    
    func loadObservers() {
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        //print("ServerRepository: I sense that value of \(keyPath) changed to \(change![NSKeyValueChangeNewKey]!)")
    }
    
    func removeObservers() {
        
    }
    
    deinit {
        deinitCanary = true
    }
    
    func get(server : Int, library : Int) {
        
        if(user.loggedin == false || user.authentication_token == "" || servers.results.count == 0 || libraries.results.count == 0) {
            print("Tried to get movies, but there were no servers to query.")
            return
        }
        
        foundResults = false
        queryInProgress = true
        libraryIndex = library
        type = libraries.results[library].type
        
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
        
        results = []
        parser = NSXMLParser(data: data)
        parser.delegate = self
        parser.parse()
    }
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {

        
        if type == "movie" {
            
            if elementName == "Video" {
                
                results.append(Movie())
                
                for (k,v) in attributeDict {
                    
                    if results.last!.respondsToSelector(Selector(k)) && !NSObject.respondsToSelector(Selector(k)) {
                        results.last!.setValue(v, forKey: k)
                    }
                }
                
            } else if elementName == "Media" && results.count > 0{
                
                (results.last! as! Movie).media.append(MovieMedia()) //(results.last! as! Movie)
                
                for (k,v) in attributeDict {
                    
                    if results.last!.respondsToSelector(Selector(k)) && !NSObject.respondsToSelector(Selector(k)) {
                        results.last!.setValue(v, forKey: k)
                    }
                }
                
            } else if elementName == "Part" && results.count > 0 && (results.last! as! Movie).media.count > 0 {
                
                let part = MovieMediaPart()
                
                for (k,v) in attributeDict {
                    
                    if part.respondsToSelector(Selector(k)) && !NSObject.respondsToSelector(Selector(k)) {
                        part.setValue(v, forKey: k)
                    }
                }
                
                (results.last! as! Movie).media.last!.parts.append(part)
            }
            
        } else if type == "show" {

        } else if type == "artist" {
            
        } else {
            // type unknown
        }
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
    }
    
    func parserDidEndDocument(parser: NSXMLParser) {
        if results.count > 0 {
            print("found \(results.count) \(type)s in \(servers.results[servers.selectedServer].name) -> \(libraries.results[libraryIndex].title)")
            
            foundResults = true
        }
        queryInProgress = false
    }
}