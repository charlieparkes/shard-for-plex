/*
 Shard by Charlie Mathews & Sarah Burgess
 This work is licensed under a Creative Commons Attribution-NonCommercial 4.0 International License
 */

//https://forums.plex.tv/discussion/40688/retrieving-a-plex-media-servers-x-plex-token-using-the-myplex-api

import Foundation

class MovieRepository : MediaRepository {
    
    var results : [Movie] = []
    
    override func processResponse(data : NSData) {
        
        print("as movies")
        
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
            
        } else if elementName == "Media" && results.count > 0{
            
            results.last!.media.append(MovieMedia()) //(results.last! as! Movie)
            
            for (k,v) in attributeDict {
                
                if results.last!.respondsToSelector(Selector(k)) && !NSObject.respondsToSelector(Selector(k)) {
                    results.last!.setValue(v, forKey: k)
                }
            }
            
        } else if elementName == "Part" && results.count > 0 && results.last!.media.count > 0 {
            
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