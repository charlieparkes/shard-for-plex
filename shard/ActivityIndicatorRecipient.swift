//
//  ActivityIndicatorRecipient.swift
//  shard
//
//  Created by Charles Mathews on 5/8/16.
//  Copyright © 2016 Charlie Mathews. All rights reserved.
//

import UIKit

class ActivityIndicatorRecipient {

    let container: UIView = UIView()
    let loadingView: UIView = UIView()
    let actInd: UIActivityIndicatorView = UIActivityIndicatorView()
    
    func showActivityIndicatory(uiView: UIView) {
        container.frame = uiView.frame
        container.center = uiView.center
        container.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.3)
        
        loadingView.frame = CGRectMake(0, 0, 80, 80)
        loadingView.center = uiView.center
        container.backgroundColor = UIColor(red: 68, green: 68, blue: 68, alpha: 0.7)
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        
        actInd.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
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


}
