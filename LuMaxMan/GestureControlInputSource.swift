//
//  GestureControlInputSource.swift
//  LuMaxMan
//
//  Created by admin on 13.01.16.
//
//

import UIKit
import simd

class GestureControlInputSource: ControlInputSourceType {
    
    /// `ControlInputSourceType` delegates.
    weak var gameStateDelegate: ControlInputSourceGameStateDelegate?
    
    weak var delegate: ControlInputSourceDelegate?
    
    func move(direction:UISwipeGestureRecognizerDirection) {
        
        switch direction {
        case UISwipeGestureRecognizerDirection.Left:
            delegate?.updateDisplacement(float2(x:-1, y:0))
        case UISwipeGestureRecognizerDirection.Right:
            delegate?.updateDisplacement(float2(x:1, y:0))
        case UISwipeGestureRecognizerDirection.Up:
            delegate?.updateDisplacement(float2(x:0, y:1))
        case UISwipeGestureRecognizerDirection.Down:
            delegate?.updateDisplacement(float2(x:0, y:-1))
        default:
            break;
        }
        
        
    }
}