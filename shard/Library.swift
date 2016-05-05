/*
 Shard by Charlie Mathews & Sarah Burgess
 This work is licensed under a Creative Commons Attribution-NonCommercial 4.0 International License
 */

import Foundation

/*
 <MediaContainer size="12" allowSync="0" identifier="com.plexapp.plugins.library" mediaTagPrefix="/system/bundle/media/flags/" mediaTagVersion="1461352094" title1="Plex Library">
 <Directory allowSync="1" art="/:/resources/movie-fanart.jpg" composite="/library/sections/12/composite/1461135702" filters="1" refreshing="0" thumb="/:/resources/video.png" key="12" type="movie" title="BodyShred" agent="com.plexapp.agents.none" scanner="Plex Video Files Scanner" language="xn" uuid="c9a11a0a-8921-4b85-86c1-adb042eba22b" updatedAt="1461135702" createdAt="1458958859">
 <Location id="13" path="P:\Workouts\BodyShred"/>
 </Directory>
 ...
 */

class Library : NSObject {
    var filters = ""
    var key = ""
    var type = ""
    var title = ""
    var uuid = ""
    var updatedAt = ""
    var createdAt = ""
}