/*
 Shard by Charlie Mathews & Sarah Burgess
 This work is licensed under a Creative Commons Attribution-NonCommercial 4.0 International License
 */

import Foundation
import UIKit

let user = User.sharedInstance
let servers = ServerRepository.sharedInstance

struct Constants {
    
    static let product = "Shard"
    static let version = "0.1"
    static let systemVersion = UIDevice.currentDevice().systemVersion
    static let model = UIDevice.currentDevice().model
    static let name = UIDevice.currentDevice().name
    static let uniqueID = NSUUID().UUIDString
    
    struct PLEX_API {
        static let signin : String = "https://plex.tv/users/sign_in.json"
        static let servers : String = "https://plex.tv/pms/servers.xml"
    }
    
    struct Defaults {
        static let token_key : String = "shard_token"
    }
    
    static let KVO_Options = NSKeyValueObservingOptions([.New, .Old])
    
}
