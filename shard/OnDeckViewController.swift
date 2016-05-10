/*
 Shard by Charlie Mathews & Sarah Burgess
 This work is licensed under a Creative Commons Attribution-NonCommercial 4.0 International License
 */

//https://coderwall.com/p/su1t1a/ios-customized-activity-indicator-with-swift

import UIKit

class OnDeckViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    let media : OnDeckRepository = OnDeckRepository()
    var server : String = ""
    
    var refreshControl = UIRefreshControl()
    
    let container: UIView = UIView()
    let loadingView: UIView = UIView()
    let actInd: UIActivityIndicatorView = UIActivityIndicatorView()
    
    func showActivityIndicatory(uiView: UIView) {
        container.frame = uiView.frame
        container.center = uiView.center
        container.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0)
        
        loadingView.frame = CGRectMake(0, 0, 80, 80)
        loadingView.center = uiView.center
        loadingView.backgroundColor = UIColor(red: 0.12, green: 0.29, blue: 0.43, alpha: 0.7)
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        
        actInd.frame = CGRectMake(0.0, 0.0, 35.0, 35.0);
        actInd.activityIndicatorViewStyle =
            UIActivityIndicatorViewStyle.WhiteLarge
        actInd.center = CGPointMake(loadingView.frame.size.width / 2,
                                    loadingView.frame.size.height / 2);
        loadingView.addSubview(actInd)
        container.addSubview(loadingView)
        uiView.addSubview(container)
        actInd.startAnimating()
    }
    
    func hideActivityIndicator() {
        actInd.stopAnimating()
        container.removeFromSuperview()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showActivityIndicatory(self.view)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        if servers.foundResults == false || servers.queryInProgress == true {
            servers.addObserver(self, forKeyPath: "foundResults", options: Constants.KVO_Options, context: nil)
        } else if servers.foundResults == true && servers.results.count > 0 {
            server = servers.results[servers.selectedServer].name
            media.addObserver(self, forKeyPath: "foundResults", options: Constants.KVO_Options, context: nil)
            media.get()
        }
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadObservers() {
        //servers.addObserver(self, forKeyPath: "foundResults", options: Constants.KVO_Options, context: nil)
        //media.addObserver(self, forKeyPath: "foundResults", options: Constants.KVO_Options, context: nil)
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        if keyPath == "foundResults" {
            if server == "" && servers.foundResults == true && servers.results.count > 0 {
                server = servers.results[servers.selectedServer].name
                servers.removeObserver(self, forKeyPath: "foundResults", context: nil)
                media.addObserver(self, forKeyPath: "foundResults", options: Constants.KVO_Options, context: nil)
                media.get()
            } else if server != "" && media.foundResults == true && media.results.count > 0 {
                hideActivityIndicator()
                reloadCollection()
            }
        } else if keyPath == "imageDownloadComplete" {
            
            let target = object as! MediaImageData
            
            let path = NSIndexPath(forItem: target.item, inSection: 0)
            collectionView.reloadItemsAtIndexPaths([path])
            object?.removeObserver(self, forKeyPath: "imageDownloadComplete")
        }
    }
    
    deinit {
        if server == "" {
            servers.removeObserver(self, forKeyPath: "foundResults", context: nil)
        } else {
            media.removeObserver(self, forKeyPath: "foundResults", context: nil)
        }
        
        for r in media.results {
            if r.coverData.downloadInProgress == true {
                r.coverData.task!.cancel()
                r.coverData.removeObserver(self, forKeyPath: "imageDownloadComplete")
            }
        }
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return media.results.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("OnDeckCell", forIndexPath: indexPath) as! VideoCell
        
        if(media.results[indexPath.item].coverData.data != NSData()) {
            cell.cover.image = UIImage(data: media.results[indexPath.item].coverData.data)!
        } else {
            cell.cover.image = UIImage(named: "movie_cover")
        }
        
        return cell
    }
    
    //override func collectionView
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate == false {
            loadVisibleMediaImages()
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        loadVisibleMediaImages()
    }
    
    func loadVisibleMediaImages() {
        if let indicies : [NSIndexPath] = collectionView.indexPathsForVisibleItems() {
            for i in indicies {
                if media.results[i.item].coverData.imageDownloadComplete == false && media.results[i.item].coverData.downloadInProgress == false {
                    loadImage(i.item)
                }
            }
        }
    }
    
    func reloadCollection() {
        collectionView.reloadData()
        collectionView.reloadSections(NSIndexSet(index: 0))
        loadVisibleMediaImages()
    }
    
    
    func loadImage(index : Int) {
        if(media.results.count > index) {
            let base = servers.results[servers.selectedServer].getURL()
            
            if true {//media.type == "movie" {
                let m = media.results[index] as! Movie
                
                if(m.thumb == "") {
                    print("no thumb for the movie...")
                    return
                }
                
                var url = base
                url += "/photo/:/transcode?url=" //path-to-image&width=50&height=50
                url += m.thumb
                url += "&width=200&height=300"
                
                if let checkedURL = NSURL(string: url) {
                    media.results[index].coverData.item = index
                    media.results[index].coverData.addObserver(self, forKeyPath: "imageDownloadComplete", options: Constants.KVO_Options, context: nil)
                    media.results[index].coverData.get(checkedURL)
                    
                    /*
                     getDataFromUrl(checkedURL) { (data, response, error)  in
                     dispatch_async(dispatch_get_main_queue()) { () -> Void in
                     guard let d = data where error == nil else { return }
                     media.results[index].coverData = d
                     print(d)
                     let path = NSIndexPath(forItem: index, inSection: 0)
                     print("Image \(index) loaded for \(m.title)")
                     self.collectionView!.reloadItemsAtIndexPaths([path])
                     }
                     }
                     */
                }
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "showMovie" {
            let backItem = UIBarButtonItem()
            backItem.title = "On Deck"
            navigationItem.backBarButtonItem = backItem
            
            let dest = segue.destinationViewController as! MovieDetailViewController
            
            let cell = sender as! UICollectionViewCell
            let indexPath = collectionView!.indexPathForCell(cell)
            dest.media = media.results[indexPath!.item] as! Movie
        }
        
    }

}
