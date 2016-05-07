/*
 Shard by Charlie Mathews & Sarah Burgess
 This work is licensed under a Creative Commons Attribution-NonCommercial 4.0 International License
 */

import UIKit

private let reuseIdentifier = "VideoCell"

class MovieLibraryCollectionViewController: UICollectionViewController {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    var refreshControl = UIRefreshControl()
    var observersActive : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl.addTarget(self, action: #selector(reload), forControlEvents: .ValueChanged)
        collectionView?.addSubview(refreshControl)
        collectionView?.alwaysBounceVertical = true
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }

        // Register cell classes
        //self.collectionView!.registerClass(VideoCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        if libraries.foundResults == true && libraries.results.count > 0 {
            loadObservers()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func reload() {
        if(servers.foundResults == true && libraries.foundResults == true && libraries.results.count > 0) {
            media.get(servers.selectedServer, library: libraries.selectedLibrary)
        }
    }
    
    func loadObservers() {
        if(libraries.results.count > 0) {
            observersActive = true
            media.addObserver(self, forKeyPath: "deinitCanary", options: Constants.KVO_Options, context: nil)
            media.addObserver(self, forKeyPath: "foundResults", options: Constants.KVO_Options, context: nil)
        }
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        if keyPath == "deinitCanary" {
            removeObservers()
        } else if keyPath == "foundResults" && media.foundResults == true {
            reloadCollection()
            refreshControl.endRefreshing()
        } else if keyPath == "imageDownloadComplete" {
            
            let target = object as! MediaImageData
            
            let path = NSIndexPath(forItem: target.item, inSection: 0)
            self.collectionView!.reloadItemsAtIndexPaths([path])
            object?.removeObserver(self, forKeyPath: "imageDownloadComplete")
        }
    }
    
    func removeObservers() {
        if(observersActive) {
            observersActive = false
            media.removeObserver(self, forKeyPath: "deinitCanary", context: nil)
            media.removeObserver(self, forKeyPath: "foundResults", context: nil)
        }
        for r in media.results {
            if r.coverData.downloadInProgress == true {
                r.coverData.task!.cancel()
                r.coverData.removeObserver(self, forKeyPath: "imageDownloadComplete")
            }
        }
    }
    
    deinit {
        removeObservers()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(libraries.results.count > 0 && libraries.selectedLibrary < libraries.results.count) {
            return media.results.count
        } else {
            return 0
        }
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! VideoCell
        
        if(media.results[indexPath.item].coverData.imageDownloadComplete == true) {
            let d : NSData = media.results[indexPath.item].coverData.data
            let i : UIImage = UIImage(data: d)!
            cell.cover.image = i
        }

        return cell
    }
    
    override func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        //loadVisibleMediaImages()
    }
    
    func loadVisibleMediaImages() {
        if let indicies : [NSIndexPath] = collectionView!.indexPathsForVisibleItems() {
            for i in indicies {
                loadImage(i.item)
            }
        }
    }
    
    func reloadCollection() {
        collectionView!.reloadData()
        collectionView!.reloadSections(NSIndexSet(index: 0))
        loadVisibleMediaImages()
    }
    
    
    func loadImage(index : Int) {
        if(media.results.count > index) {
            let base = servers.results[servers.selectedServer].getURL()
            
            if media.type == "movie" {
                let m = media.results[index] as! Movie
                
                if(m.thumb == "") {
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
     /*
        if let checkedUrl = NSURL(string: url) {
            getDataFromUrl(checkedUrl) { (data, response, error)  in
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    guard let d = data where error == nil else { return }
                    img.data = d
                    self.reloadCollection()
                }
            }
        }
         */
    }
    
    func getDataFromUrl(url:NSURL, completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            completion(data: data, response: response, error: error)
            }.resume()
    }
 
    
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */

}
