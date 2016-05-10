/*
 Shard by Charlie Mathews & Sarah Burgess
 This work is licensed under a Creative Commons Attribution-NonCommercial 4.0 International License
 */

//https://forums.plex.tv/discussion/40688/retrieving-a-plex-media-servers-x-plex-token-using-the-myplex-api

import Foundation

class OnDeckRepository : MediaRepository {
    
    func get() {
        get(0, library: 0)
    }

    override func get(server: Int, library: Int) {
            
        if(user.loggedin == false || user.authentication_token == "" || servers.results.count == 0) {
            print("Tried to get movies, but there were no servers to query.")
            return
        }
        
        foundResults = false
        queryInProgress = true
        libraryIndex = library
        type = "ondeck"
        
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
        
        let url = "\(servers.results[server].getURL())\(Constants.WEB_API.ondeck)"
        print("\nGET \(url)")
        
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        
        request.HTTPMethod = "GET"
        let task = session.downloadTaskWithRequest(request)
        task.resume()
    }
    
    override func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        
        let data = NSData(contentsOfURL: location)!
        NSOperationQueue.mainQueue().addOperationWithBlock({
            self.processResponse(data)
        })
    }
    
    override func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        
        for (k,v) in attributeDict {
            if k == "type" {
                if v.containsString("movie") {
                    type = "movie"
                } else if v.containsString("episode") {
                    type = "episode"
                }
            }
        }
        
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
            
        } else if type == "episode" {
            
            
        } else {
            // type unknown
        }
    }
    
    override func parserDidEndDocument(parser: NSXMLParser) {
        if results.count > 0 {
            print("Found \(results.count) in \(servers.results[servers.selectedServer].name) -> On Deck")
            
            foundResults = true
        }
        queryInProgress = false
    }
}