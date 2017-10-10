//
//  ActivityIndicator.swift
//  OnTheMap
//
//  Created by Lindsey Renee Eaton on 6/13/17.
//  Copyright © 2017 Mark Tapia. All rights reserved.
//

import Foundation
import UIKit

class PhotoActivityIndicator {
    
    static var width: CGFloat {
        
        let screenWidth = UIScreen.main.bounds.width
        return screenWidth / 3 - 10
    }
    var activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: width, height: width))
    
    
    func getActivityIndicator() -> UIActivityIndicatorView {
        setupActivityIndicator()
        return activityIndicator
    }
    
    private func setupActivityIndicator() {
        let backgroundColor = UIColor.darkGray
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.backgroundColor = backgroundColor
        activityIndicator.layer.cornerRadius = 7
        activityIndicator.startAnimating()
    }
    
    
}
