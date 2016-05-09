/*
 Shard by Charlie Mathews & Sarah Burgess
 This work is licensed under a Creative Commons Attribution-NonCommercial 4.0 International License
 */

import UIKit

class OnDeckViewController: UICollectionViewController {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    var refreshControl = UIRefreshControl()
    var observedClass : OnDeckRepository = OnDeckRepository()
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
            observedClass.get()
            
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
            reload()
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
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
