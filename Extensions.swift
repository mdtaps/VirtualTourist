//
//  Extensions.swift
//  VirtualTourist
//
//  Created by Mark Tapia on 8/24/17.
//  Copyright © 2017 Mark Tapia. All rights reserved.
//

import UIKit

extension UIView {
    
    func shift(by amount: CGFloat, deleteMode status: Bool) {
        
        var operation: (CGFloat, CGFloat) -> CGFloat {
            
            return status ? (-) : (+)
        }
        
        let y = self.frame.origin.y
        
        self.frame.origin.y = operation(y, amount)
    }
}
