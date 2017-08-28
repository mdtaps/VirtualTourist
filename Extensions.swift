//
//  Extensions.swift
//  VirtualTourist
//
//  Created by Mark Tapia on 8/24/17.
//  Copyright © 2017 Mark Tapia. All rights reserved.
//

import UIKit
import MapKit

extension UIView {
    
    func shift(by shiftAmount: CGFloat, inDirection operation: (CGFloat, CGFloat) -> (CGFloat)) {
        
        let y = self.frame.origin.y
        
        self.frame.origin.y = operation(y, shiftAmount)
    }
}
