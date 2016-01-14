//
//  OrientationComponent.swift
//  LuMaxMan
//
//  Created by Alexander Holzer on 15/12/15.
//
//  Abstract:
//  A `GKComponent` that enables an animated entity to track its current orientation (i.e. the direction it is facing). This information is used when choosing an appropriate animation.

import SpriteKit
import GameplayKit

class OrientationComponent: GKComponent {
    // MARK: Properties
    
    var zRotation: CGFloat = 0.0 {
        didSet {
            let twoPi = CGFloat(M_PI * 2)
            zRotation = (zRotation + twoPi) % twoPi
        }
    }
    
    var direction: Direction {
        get {
            return Direction(zRotation: zRotation)
        }
        
        set {
            zRotation = newValue.zRotation
        }
    }
}