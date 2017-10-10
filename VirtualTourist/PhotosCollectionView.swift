//
//  PhotosCollectionView.swift
//  VirtualTourist
//
//  Created by Mark Tapia on 10/9/17.
//  Copyright © 2017 Mark Tapia. All rights reserved.
//

import UIKit

extension UICollectionView {
    
    func setupPhotoCollectionView() {
        
        self.collectionViewLayout = layout
    }
    
    private var layout: UICollectionViewFlowLayout {
        
        let layout = UICollectionViewFlowLayout()
        let width = UIScreen.main.bounds.width
        layout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        layout.itemSize = CGSize(width: width / 3 - 10, height: width / 3 - 10)
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        return layout
    }
}
