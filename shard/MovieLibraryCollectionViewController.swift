/*
 Shard by Charlie Mathews & Sarah Burgess
 This work is licensed under a Creative Commons Attribution-NonCommercial 4.0 International License
 */

import UIKit

class MovieLibraryCollectionViewController: UICollectionViewController {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    var media : MediaRepository = MediaRepository()
    var server : Int = 0
    var library : Int = 0
    
    var selected_item : Int = 0
    
    func getIfLibraryChanged() {
        if(servers.selectedServer != server || libraries.selectedLibrary != library) {
            updateSelectedMedia()
            getLibrary()
        }
    }
    
    func getLibrary() {
        refreshControl.endRefreshing()
        showActivityIndicatory(self.view)
        media.get(server, library: library)
    }
    
    func updateSelectedMedia() {
        server = servers.selectedServer
        library = libraries.selectedLibrary
    }
    
    var refreshControl = UIRefreshControl()
    var observersActive : Bool = false
    
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
        
        updateSelectedMedia()
        
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
        
        getLibrary()
    }
    
    override func viewDidAppear(animated: Bool) {
        getIfLibraryChanged()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func reload() {
        if(servers.foundResults == true && libraries.foundResults == true && libraries.results.count > 0) {
            getLibrary()
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
            
            self.reloadCollection()
            self.hideActivityIndicator()
            
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

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "showMovie" {
            let backItem = UIBarButtonItem()
            backItem.title = libraries.results[library].title
            navigationItem.backBarButtonItem = backItem
            
            let dest = segue.destinationViewController as! MovieDetailViewController
            
            let cell = sender as! UICollectionViewCell
            let indexPath = collectionView!.indexPathForCell(cell)
            dest.media = media.results[indexPath!.item] as! Movie
        }
        
    }

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
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("VideoCell", forIndexPath: indexPath) as! VideoCell
        
        if(media.results[indexPath.item].coverData.imageDownloadComplete == true) {
            cell.cover.image = UIImage(data: media.results[indexPath.item].coverData.data)!
        } else {
            cell.cover.image = UIImage(named: "movie_cover")
        }

        return cell
    }
    
    //override func collectionView
    
    override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate == false {
            loadVisibleMediaImages()
        }
    }
    
    override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        loadVisibleMediaImages()
    }

    func loadVisibleMediaImages() {
        if let indicies : [NSIndexPath] = collectionView!.indexPathsForVisibleItems() {
            for i in indicies {
                if media.results[i.item].coverData.imageDownloadComplete == false && media.results[i.item].coverData.downloadInProgress == false {
                    loadImage(i.item)
                }
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
                    url += "&width=120&height=180"
                
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
