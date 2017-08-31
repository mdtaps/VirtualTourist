//
//  TravelLocationsVCModel.swift
//  VirtualTourist
//
//  Created by Mark Tapia on 8/28/17.
//  Copyright © 2017 Mark Tapia. All rights reserved.
//

import Foundation
import UIKit

class DeleteMode {
    
    var isOn: Bool
    
    init(isOn: Bool) {
        self.isOn = isOn
    }
    
    func toggle() {
        isOn = !isOn
    }
}
