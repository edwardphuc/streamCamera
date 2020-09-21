//
//  GridLayout.swift
//  SentirLite
//
//  Created by Hung Nguyen on 7/27/17.
//  Copyright © 2017 Skylab. All rights reserved.
//

import UIKit

class GridLayout: UICollectionViewFlowLayout {

    
    var numberOfColumns: Int = 2
    
    init(numberOfColumns: Int) {
        super.init()
        minimumLineSpacing = 2
        minimumInteritemSpacing = 2
        self.numberOfColumns = numberOfColumns
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var itemSize: CGSize {
        get {
                if let collectionView = collectionView {
                    let itemWidth: CGFloat = (collectionView.frame.width/CGFloat(self.numberOfColumns)) - 3
                    var itemHeight: CGFloat = 140.0
                    if UIDevice.current.userInterfaceIdiom == .pad {
                        itemHeight = 300
                    }
                    
                    return CGSize(width: itemWidth, height: itemHeight)
                }
            
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
