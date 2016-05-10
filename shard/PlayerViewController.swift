/*
 Shard by Charlie Mathews & Sarah Burgess
 This work is licensed under a Creative Commons Attribution-NonCommercial 4.0 International License
 */

// https://github.com/piemonte/Player

import UIKit

class PlayerViewController: Player {//UIViewController, PlayerDelegate {
    
    //let player : Player = Player()
    var streamingURL = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        //player.delegate = self
        //player.view.frame = self.view.bounds
        
        //self.addChildViewController(self.player)
        //self.view.addSubview(self.player.view)
        //self.player.didMoveToParentViewController(self)
    }
    
    func startPlayer() {
        let videoURL: NSURL = NSURL(fileURLWithPath: streamingURL)
        self.setUrl(videoURL)
        
        //player.fillMode = "AVLayerVideoGravityResizeAspect"
        
        self.playFromBeginning()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func playerReady(player: Player) {
        
    }
    
    func playerPlaybackDidEnd(player: Player) {
        
    }
    
    func playerPlaybackStateDidChange(player: Player) {
        
    }
    
    func playerBufferingStateDidChange(player: Player) {
        
    }

    func playerPlaybackWillStartFromBeginning(player: Player) {
        
    }

}
