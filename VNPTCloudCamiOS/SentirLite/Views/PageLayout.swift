//
//  PageLayout.swift
//  SentirLite
//
//  Created by Hung Nguyen on 7/27/17.
//  Copyright © 2017 Skylab. All rights reserved.
//

import UIKit

class PageLayout: UICollectionViewFlowLayout {

    
    var itemHeight: CGFloat = 265
    
    init(itemHeight: CGFloat) {
        super.init()
        minimumLineSpacing = 2
        minimumInteritemSpacing = 2
        
        self.itemHeight = itemHeight
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var itemSize: CGSize {
        get {
            if let collectionView = collectionView {
                let itemWidth: CGFloat = collectionView.frame.width
                return CGSize(width: itemWidth, height: self.itemHeight)
            }
            
            // Default fallback
            return CGSize(width: 100, height: 100)
        }
        set {
            super.itemSize = newValue
        }
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        return proposedContentOffset
    }

    
    
}
