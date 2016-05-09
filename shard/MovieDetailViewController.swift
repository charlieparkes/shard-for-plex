/*
 Shard by Charlie Mathews & Sarah Burgess
 This work is licensed under a Creative Commons Attribution-NonCommercial 4.0 International License
 */

import UIKit

class MovieDetailViewController: UIViewController {
    
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var moviePoster: UIImageView!
    
    var media : Movie = Movie()
    let base = servers.results[servers.selectedServer].getURL()
    var cover = MediaImageData()
    var observersLoaded : Bool = false
    var coverObserverLoaded : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imageHeight = (UIScreen.mainScreen().bounds.height)/3
        
        /*
        let x = coverImage.frame.origin.x
        let y = coverImage.frame.origin.y
        let h = imageHeight
        let w = coverImage.frame.width
        coverImage.frame = CGRectMake(x, y, h, w)
        */
        
        let height = Int(imageHeight)*2
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
        
        movieTitle.text = media.title
        moviePoster.image = UIImage(data: media.coverData.data)
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
            if let i = UIImage(data: cover.data) {
                coverImage.image = i
                coverObserverLoaded = false
                cover.removeObserver(self, forKeyPath: "imageDownloadComplete")
            }
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
