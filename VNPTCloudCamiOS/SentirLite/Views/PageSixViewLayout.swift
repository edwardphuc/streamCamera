//
//  GridSixViewLayout.swift
//  SentirLite
//
//  Created by Hung Nguyen on 7/27/17.
//  Copyright © 2017 Skylab. All rights reserved.
//

import UIKit
import SquareMosaicLayout

class PageSixViewLayout: SquareMosaicLayout, SquareMosaicDataSource {
   
    convenience init() {
        self.init(direction: SquareMosaicDirection.vertical)
        layoutPattern(for: 3)
        self.dataSource = self
    }
    
    func layoutPattern(for section: Int) -> SquareMosaicPattern {
        return FMMosaicLayoutCopyPattern()
    }
    
    func layoutSeparatorBetweenSections() -> CGFloat {
        return 2.0
    }
   
}
class FMMosaicLayoutCopyPattern: SquareMosaicPattern {
    
    func patternBlocks() -> [SquareMosaicBlock] {
        return [
            
            FMMosaicLayoutCopyBlock6()
        ]
    }
}
public class FMMosaicLayoutCopyBlock6: SquareMosaicBlock {
    
    var min = 0
    var max = 0
    
    public func blockFrames() -> Int {
        return 6
    }
    
    public func blockFrames(origin: CGFloat, side: CGFloat) -> [CGRect] {
        
        var min = side / 4.0
        var max = side - min - min
        max = 242
        min = 120
        if UIDevice().screenType == .iPhone5 {
            max = 208
            min = 103
        } else if UIDevice().screenType == .iPhone6Plus {
            max = 272
            min = 135
        } else if UIDevice().screenType == .unknown {
            max = 242
            min = 120
        }
        if UIDevice.current.userInterfaceIdiom == .pad {
            max = 500
            min = 245
        }

        var frames = [CGRect]()
        frames.append(CGRect(x: 0, y: origin, width: max, height: max))
        frames.append(CGRect(x: max + 2, y: origin, width: min, height: min))
        frames.append(CGRect(x: max + 2, y: origin + min + 2, width: min, height: min))
        frames.append(CGRect(x: 0, y: origin + max + 2 , width: min, height: min))
        frames.append(CGRect(x: min + 2, y: origin + max + 2, width: min, height: min))
        frames.append(CGRect(x: max + 2, y: origin + max + 2, width: min, height: min))
        
        return frames
    }
}
