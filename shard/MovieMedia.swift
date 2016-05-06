/*
 Shard by Charlie Mathews & Sarah Burgess
 This work is licensed under a Creative Commons Attribution-NonCommercial 4.0 International License
 */


import Foundation

class MovieMedia : NSObject {
    
    var parts : [MovieMediaPart] = []
    
    var videoResolution = ""
    var id = ""
    var duration = ""
    var bitrate = ""
    var width = ""
    var height = ""
    var aspectRatio = ""
    var optimizedForStreaming = ""
    var videoProfile = ""
    
}