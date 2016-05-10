/*
 Shard by Charlie Mathews & Sarah Burgess
 This work is licensed under a Creative Commons Attribution-NonCommercial 4.0 International License
 */

//https://coderwall.com/p/su1t1a/ios-customized-activity-indicator-with-swift

import UIKit

class OnDeckViewController: UIViewController {
    
    let media : OnDeckRepository = OnDeckRepository()
    var server : String = ""
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
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
            }
        }
    }
    
    deinit {
        if server == "" {
            servers.removeObserver(self, forKeyPath: "foundResults", context: nil)
        } else {
            media.removeObserver(self, forKeyPath: "foundResults", context: nil)
        }
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
