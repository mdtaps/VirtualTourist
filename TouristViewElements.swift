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
    
    convenience init(view: UIView) {
        let frame = CGRect(x: view.frame.maxX,
                           y: view.frame.maxY,
                           width: view.frame.width, height: 80 )
        
        self.init(frame: frame)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .red
        self.textColor = .white
        self.textAlignment = .center
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
