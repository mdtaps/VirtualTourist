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
    
    convenience init(below view: UIView) {
        self.init(frame: view.frame)
        
        self.backgroundColor = .red
        self.textColor = .white
        self.textAlignment = .center
        self.text = "Tap Pins To Delete"
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.frame = CGRect(x: frame.minX,
                            y: frame.maxY,
                            width: frame.width,
                            height: Constants.ShiftAmount)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
