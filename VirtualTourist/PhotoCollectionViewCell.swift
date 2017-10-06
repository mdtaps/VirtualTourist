//
//  PhotoCollectionViewCell.swift
//  VirtualTourist
//
//  Created by Mark Tapia on 9/12/17.
//  Copyright © 2017 Mark Tapia. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func prepareForReuse() {
        self.imageView.image = nil
        self.backgroundView = PhotoActivityIndicator().getActivityIndicator()
    }
    
}
