//
//  Extensions.swift
//  VirtualTourist
//
//  Created by Mark Tapia on 8/24/17.
//  Copyright © 2017 Mark Tapia. All rights reserved.
//

import UIKit

extension UIView {
    
    func shift(by amount: CGFloat, with operation: (Double, Double) -> Double) {
                
        let y = self.frame.origin.y
        
        self.frame.origin.y = CGFloat(operation(Double(y), Double(amount)))
    }
    
    func shiftSubviews(with operation: (Double, Double) -> Double) {
        
        for view in self.subviews {
            view.shift(by: Constants.ShiftAmount, with: operation)
        }
    }
}
