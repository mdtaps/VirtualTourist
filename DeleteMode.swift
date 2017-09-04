//
//  TravelLocationsVCModel.swift
//  VirtualTourist
//
//  Created by Mark Tapia on 8/28/17.
//  Copyright © 2017 Mark Tapia. All rights reserved.
//

import Foundation
import UIKit

enum DeleteMode {
    
    case On
    case Off
    
    mutating func toggle() {
        switch self {
        case .On:
            self = .Off
        case .Off:
            self = .On
        }
    }
    
    var opertation: (Double, Double) -> Double {
        switch self {
        case .On:
            return (-)
        case .Off:
            return (+)
        }
    }
}
