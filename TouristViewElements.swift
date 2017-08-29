//
//  TouristViewElements.swift
//  VirtualTourist
//
//  Created by Mark Tapia on 8/23/17.
//  Copyright © 2017 Mark Tapia. All rights reserved.
//

import Foundation
import UIKit

class DeleteModeLabel: UILabel {
    
    convenience init() {
        self.init()

        self.backgroundColor = .red
        self.textColor = .white
        self.textAlignment = .center
        self.text = "Tap Pins To Delete"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
