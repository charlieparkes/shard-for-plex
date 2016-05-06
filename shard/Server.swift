/*
 Shard by Charlie Mathews & Sarah Burgess
 This work is licensed under a Creative Commons Attribution-NonCommercial 4.0 International License
 */

import Foundation

/* EXAMPLE SERVER RESPONSE
 
 <MediaContainer friendlyName="myPlex" identifier="com.plexapp.plugins.myplex" machineIdentifier="3455a17d5709f7636633515aeb2e6fce109c0904" size="1">
 <Server accessToken="QY3QtYxw1qq11j5wxTZ6" name="Home" address="73.210.156.39" port="80" version="0.9.16.6.1993-5089475" scheme="http" host="73.210.156.39" localAddresses="192.168.1.30" machineIdentifier="8a9a82114e934bc43d14d148f1b9682cf4a9af14" createdAt="1436577163" updatedAt="1461784248" owned="1" synced="0"/>
 </MediaContainer>
 
 <MediaContainer friendlyName="myPlex" identifier="com.plexapp.plugins.myplex" machineIdentifier="cefe3784954fc596fd5bc7a3178642f90cda375b" size="1">
 <Server accessToken="nNiB1nKqsEZacgFs78dV" name="Home" address="73.210.156.39" port="80" version="0.9.16.6.1993-5089475" scheme="http" host="73.210.156.39" localAddresses="192.168.1.30" machineIdentifier="8a9a82114e934bc43d14d148f1b9682cf4a9af14" createdAt="1436577163" updatedAt="1462478566" owned="0" synced="0" sourceTitle="luxprimus" ownerId="2802436" home="0"/>
 </MediaContainer>
 */

class Server : NSObject {
    var name = ""
    var address = ""
    var port = ""
    var scheme = ""
    var machineIdentifier = ""
    var owned = ""
    var version = ""
    var createdAt = ""
    var updatedAt = ""
    var accessToken = ""
    
    func getURL() -> String {
        return scheme + "://" + address + ":" + port
    }
}
