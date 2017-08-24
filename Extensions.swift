//
//  Extensions.swift
//  VirtualTourist
//
//  Created by Mark Tapia on 8/24/17.
//  Copyright © 2017 Mark Tapia. All rights reserved.
//

import UIKit

extension CGFloat {
    
    mutating func shift(by shiftAmount: CGFloat, inDirection operation: (CGFloat, CGFloat) -> (CGFloat)) {
        
        self = operation(self, shiftAmount)
    }
}
