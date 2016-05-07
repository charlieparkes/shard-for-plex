/*
 Shard by Charlie Mathews & Sarah Burgess
 This work is licensed under a Creative Commons Attribution-NonCommercial 4.0 International License
 */

import UIKit

private let reuseIdentifier = "VideoCell"

class MovieLibraryCollectionViewController: UICollectionViewController {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    var refreshControl = UIRefreshControl()
    var observedClass : MediaRepository = MediaRepository()
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
        self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        if libraries.foundResults == true && libraries.results.count > 0 {
            observedClass = libraries.results[libraries.selectedLibrary].contents
            loadObservers()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func reload() {
        if(servers.foundResults == true && libraries.foundResults == true && libraries.results.count > 0) {
            observedClass.get(servers.selectedServer, library: libraries.selectedLibrary)
        }
    }
    
    func loadObservers() {
        if(libraries.results.count > 0) {
            observersActive = true
            observedClass.addObserver(self, forKeyPath: "deinitCanary", options: Constants.KVO_Options, context: nil)
            observedClass.addObserver(self, forKeyPath: "foundResults", options: Constants.KVO_Options, context: nil)
        }
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        if keyPath == "deinitCanary" {
            print("movie controller sees that it's observed media repository is deinitializing")
            removeObservers()
        }
        
        if keyPath == "foundResults" {
            reloadCollection()
            refreshControl.endRefreshing()
        }
    }
    
    func removeObservers() {
        if(observersActive) {
            observersActive = false
            observedClass.removeObserver(self, forKeyPath: "deinitCanary", context: nil)
            observedClass.removeObserver(self, forKeyPath: "foundResults", context: nil)
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
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        if(libraries.results.count > 0 && libraries.selectedLibrary < libraries.results.count) {
            return observedClass.count()
        } else {
            return 0
        }
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! VideoCell
    
        
    
        return cell
    }
    
    func reloadCollection() {
        collectionView!.reloadData()
        collectionView!.reloadSections(NSIndexSet(index: 0))
        //for i in images.results{
        //    loadImage(i)
        //}
    }
    /*
    func loadImage(img : Image) {
        var url = "https://farm" + String(img.farm)
        url += ".staticflickr.com/"+img.server
        url += "/"+img.id+"_"+img.secret+"_s.jpg"
        
        //NSLog(url)
        
        if let checkedUrl = NSURL(string: url) {
            getDataFromUrl(checkedUrl) { (data, response, error)  in
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    guard let d = data where error == nil else { return }
                    img.data = d
                    self.reloadCollection()
                }
            }
        }
    }
 */

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
