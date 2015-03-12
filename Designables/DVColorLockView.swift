//
//  DVColorLockView.swift
//  DVColorLockViewDemo
//
//  Created by Dylan Vann on 2014-10-22.
//  Copyright (c) 2014 Dylan Vann. All rights reserved.
//

import Foundation
import UIKit

// DVColorLockView ovverides the backgroundColor setter for UIView. 
// Highlighting a UITableViewCell won't change the color of its DVColorLockView subviews.
// (Highlighting a UITableViewCell changes the background color of all subviews, it's annoying.)
class DVColorLockView:UIView {
    
    
//        override func drawRect(rect: CGRect) {
//            let rectanglePath = UIBezierPath(rect: CGRectMake(frame.minX, frame.minY, frame.width, frame.height))
//            UIColor.whiteColor().setFill()
//            rectanglePath.fill()
//        }

    
     required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = UIColor.whiteColor()
    }
    var lockedBackgroundColor:UIColor {
        set {
            super.backgroundColor = newValue
        }
        get {
            return super.backgroundColor!
        }
    }
    
    override var backgroundColor:UIColor? {
        set {
        }
        get {
            return super.backgroundColor
        }
    }
    
}