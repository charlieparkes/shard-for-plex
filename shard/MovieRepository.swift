/*
 Shard by Charlie Mathews & Sarah Burgess
 This work is licensed under a Creative Commons Attribution-NonCommercial 4.0 International License
 */

//https://forums.plex.tv/discussion/40688/retrieving-a-plex-media-servers-x-plex-token-using-the-myplex-api

import Foundation

class MovieRepository : MediaRepository, SelfPopulatingRepository {
    
    var observersLoaded : Bool = false
    
    var queryInProgress = false
    dynamic var foundResults = false
    var results : [Movie] = []
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
        print(url)
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
            self.processResponse(data)
        })
    }
    
    func processResponse(data : NSData) {
        
        //let string = NSString(data: data, encoding: NSASCIIStringEncoding)
        
        results = []
        parser = NSXMLParser(data: data)
        parser.delegate = self
        parser.parse()
    }
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        
        if elementName == "Video" {
            
            results.append(Movie())
            
            for (k,v) in attributeDict {
                
                if results.last!.respondsToSelector(Selector(k)) && !NSObject.respondsToSelector(Selector(k)) {
                    results.last!.setValue(v, forKey: k)
                }
            }
            
        } else if elementName == "Media" {
            
            results.last!.media.append(MovieMedia())
            
            for (k,v) in attributeDict {
                
                if results.last!.respondsToSelector(Selector(k)) && !NSObject.respondsToSelector(Selector(k)) {
                    results.last!.setValue(v, forKey: k)
                }
            }
            
        } else if elementName == "Part" {
            
            let part = MovieMediaPart()
            
            for (k,v) in attributeDict {
                
                if part.respondsToSelector(Selector(k)) && !NSObject.respondsToSelector(Selector(k)) {
                    part.setValue(v, forKey: k)
                }
            }
            
            results.last!.media.last!.parts.append(part)
        }
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
    }
    
    func parserDidEndDocument(parser: NSXMLParser) {
        if results.count > 0 {
            print("Found \(results.count) movies in \(servers.results[servers.selectedServer].name) -> \(libraries.results[libraryIndex].title)")
            
            foundResults = true
        }
        queryInProgress = false
    }
    
}