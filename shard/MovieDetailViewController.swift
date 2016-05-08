//
//  VideoDetailViewController.swift
//  shard
//
//  Created by Charles Mathews on 5/8/16.
//  Copyright © 2016 Charlie Mathews. All rights reserved.
//

import UIKit

class MovieDetailViewController: UIViewController {
    
    var media : Movie = Movie()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(media.title)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
