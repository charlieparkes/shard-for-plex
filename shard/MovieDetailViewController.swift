/*
 Shard by Charlie Mathews & Sarah Burgess
 This work is licensed under a Creative Commons Attribution-NonCommercial 4.0 International License
 */

import UIKit

class MovieDetailViewController: UIViewController {
    
    @IBOutlet weak var coverImage: UIImageView!
    //@IBOutlet weak var scrollView: UIScrollView!
    //@IBOutlet weak var coverImage: UIImageView!
    //@IBOutlet weak var movieTitle: UILabel!
    //@IBOutlet weak var moviePoster: UIImageView!
    //var movieBackground : UIImageView = UIImageView()
    
    var media : Movie = Movie()
    let base = servers.results[servers.selectedServer].getURL()
    var cover = MediaImageData()
    var observersLoaded : Bool = false
    var coverObserverLoaded : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
        scrollView.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        
        let x : CGFloat = 0
        let y : CGFloat = 0
        let h : CGFloat = scrollView.bounds.height/3
        let w : CGFloat = scrollView.bounds.width
        let frame = CGRectMake(x, y, w, h)
        print(x, " ", y, " ", w, " ", h)
        
        movieBackground.frame = frame
        movieBackground.alpha = 0
        movieBackground.contentMode = UIViewContentMode.ScaleAspectFill
        
        scrollView.contentSize = movieBackground.bounds.size
        scrollView.addSubview(movieBackground)
        
        let height = Int(h)*2
        let width = Int(Double(height)*(1.6))
        
        var url = base
        url += "/photo/:/transcode?url="
        url += media.art
        url += "&width=\(width)&height=\(height)" // x 600 y 400
        
        if let checkedURL = NSURL(string: url) {
            cover.addObserver(self, forKeyPath: "imageDownloadComplete", options: Constants.KVO_Options, context: nil)
            coverObserverLoaded = true
            cover.get(checkedURL)
        }
        */
        //movieTitle.text = media.title
        coverImage.image = UIImage(data: media.coverData.data)
 
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadObservers() {
        if(observersLoaded == false) {
            observersLoaded = true
            
            // none
        }
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        if keyPath == "imageDownloadComplete" {
            /*if let i = UIImage(data: cover.data) {
                //movieBackground.image = i
                //print(movieBackground.frame.width, " ", movieBackground.frame.height)
                coverObserverLoaded = false
                cover.removeObserver(self, forKeyPath: "imageDownloadComplete")
                
                UIView.animateWithDuration(1, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                    
                    //self.movieBackground.alpha = 0.4
                    
                    }, completion: nil )
            }*/
        }
        
    }
    
    func removeObservers() {
        if(observersLoaded == true) {
            observersLoaded = false
            
            //none
        }
        
        if(coverObserverLoaded == true) {
            coverObserverLoaded = false
            cover.removeObserver(self, forKeyPath: "imageDownloadComplete")
            
        }
    }
    
    deinit {
        removeObservers()
    }
    

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "showVideo" {

            let mediaCollection = media.media
            
            if mediaCollection.count > 0 {
                
                let videoParts = mediaCollection[0].parts
                
                if videoParts.count > 0 {
                    
                    // http://73.210.156.39:80/video/:/transcode/universal/start.m3u8?X-Plex-Platform=Chrome&copyts=1&offset=0&path=%2Flibrary%2Fmetadata%2F20736&mediaIndex=0&videoResolution=800x600&X-Plex-Token=QY3QtYxw1qq11j5wxTZ6
                    
                    var url = base
                    url += "/video/:/transcode/universal/start.m3u8"
                    url += "?X-Plex-Platform=Chrome"
                    url += "&copyts=1"
                    url += "&offset=0"
                    url += "&path=%2Flibrary%2Fmetadata%2F"
                    url += videoParts[0].id
                    url += "&mediaIndex=0"
                    url += "&videoResolution=800x600"
                    url += "&X-Plex-Token="
                    url += servers.results[servers.selectedServer].accessToken
                    
                    let dest = segue.destinationViewController as! PlayerViewController
                
                    print(url)
                    dest.streamingURL = url
                    dest.streamingURL = "http://73.210.156.39:80/video/:/transcode/universal/start.m3u8?X-Plex-Platform=Chrome&copyts=1&offset=0&path=%2Flibrary%2Fmetadata%2F20736&mediaIndex=0&videoResolution=800x600&X-Plex-Token=QY3QtYxw1qq11j5wxTZ6"
                    dest.startPlayer()
                    
                }
            }
        }
    }

}
