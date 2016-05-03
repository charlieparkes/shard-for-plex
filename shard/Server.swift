/*
 Shard by Charlie Mathews & Sarah Burgess
 This work is licensed under a Creative Commons Attribution-NonCommercial 4.0 International License
 */

import Foundation

/* EXAMPLE SERVER RESPONSE
 
 <MediaContainer friendlyName="myPlex" identifier="com.plexapp.plugins.myplex" machineIdentifier="3455a17d5709f7636633515aeb2e6fce109c0904" size="1">
 <Server accessToken="QY3QtYxw1qq11j5wxTZ6" name="Home" address="73.210.156.39" port="80" version="0.9.16.6.1993-5089475" scheme="http" host="73.210.156.39" localAddresses="192.168.1.30" machineIdentifier="8a9a82114e934bc43d14d148f1b9682cf4a9af14" createdAt="1436577163" updatedAt="1461784248" owned="1" synced="0"/>
 </MediaContainer>
 */

class Server {
    var name = ""
    var address = ""
    var port = ""
    var scheme = ""
    var machineIdentifier = ""
    var owned = ""
}
