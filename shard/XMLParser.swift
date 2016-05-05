/*
 Shard by Charlie Mathews & Sarah Burgess
 This work is licensed under a Creative Commons Attribution-NonCommercial 4.0 International License
 */

//https://github.com/drmohundro/SWXMLHash

import Foundation

class XMLParser : NSObject, NSXMLParserDelegate {
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        
        print("element start: \(elementName)")
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        print("element finish: \(elementName)")
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String) {
        
        print("string \(string)")
    }
    
    func parser(parser: NSXMLParser, foundAttributeDeclarationWithName attributeName: String, forElement elementName: String, type: String?, defaultValue: String?) {
        
        print("found attribute \(attributeName)")
    }
    
    func parser(parser: NSXMLParser, foundElementDeclarationWithName elementName: String, model: String) {
        
        print("found element \(elementName)")
    }
    
}