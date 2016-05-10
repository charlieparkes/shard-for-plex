/*
 Shard by Charlie Mathews & Sarah Burgess
 This work is licensed under a Creative Commons Attribution-NonCommercial 4.0 International License
 */

//https://github.com/mjs7231/python-plexapi/wiki/Unofficial-Plex-API-Documentation
//https://github.com/Arcanemagus/plex-api/wiki/Plex-Web-API-Overview
//https://github.com/plexinc/plex-media-player


import Foundation
import UIKit

let user = User.sharedInstance
let servers = ServerRepository.sharedInstance
let libraries = LibraryRepository.sharedInstance

struct Constants {
    
    static let product = "Shard"
    static let version = "ALPHA 0.1"
    static let systemVersion = UIDevice.currentDevice().systemVersion
    static let model = UIDevice.currentDevice().model
    static let name = UIDevice.currentDevice().name
    static let uniqueID = NSUUID().UUIDString
    
    struct PLEX_API {
        static let signin : String = "https://plex.tv/users/sign_in.json"
        static let servers : String = "https://plex.tv/pms/servers.xml"
        static let sections : String = "https://plex.tv/pms/system/library/sections" // DEPRECATED
    }
    
    struct WEB_API {
        static let sections : String = "/library/sections"
        static let ondeck : String = "/library/onDeck"
    }
    
    struct Defaults {
        static let token_key : String = "shard_token"
    }
    
    static let KVO_Options = NSKeyValueObservingOptions([.New, .Old])
    
}
