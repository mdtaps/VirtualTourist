//
//  TravelLocationsVCModel.swift
//  VirtualTourist
//
//  Created by Mark Tapia on 8/28/17.
//  Copyright © 2017 Mark Tapia. All rights reserved.
//

import Foundation
import UIKit

struct DeleteMode {
    
    static var isOn = false
    static var alertLabel = DeleteModeLabel()
    
    static var direction: (CGFloat, CGFloat) -> (CGFloat) {
        
        return isOn ? (-) : (+)
    }
    
    static func shift(views: [UIView]) {
        
        for view in views {
            view.shift(by: Constants.ShiftAmount, inDirection: direction)
        }
    }
    
    static func toggle() {
        isOn = !isOn
    }
    
    static func label(relativeTo view: UIView) -> UILabel {
        
        alertLabel.frame = CGRect(x: view.frame.minX,
                                  y: view.frame.maxY,
                                  width: view.frame.width,
                                  height: 80)
        
        return alertLabel
    }
}
