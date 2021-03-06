//
//  GameplayConfiguration.swift
//  LuMaxMan
//
//  Created by Alexander Holzer on 15/12/15.
//
//

import Foundation
import CoreGraphics

struct GameplayConfiguration {
    
    struct SceneManager {
        /// The duration of a transition between loaded scenes.
        static let transitionDuration: NSTimeInterval = 0.5
    }
    struct LumaxMan {
        /// The movement speed (in points per second).
        static let movementSpeed: CGFloat = 250.0
        static let appearDuration: NSTimeInterval = 0.5
        static let hitStateDuration: NSTimeInterval = 0.5
    }
    
    struct Enemy {
        // The static settings for enemies.
        static let movementSpeedWhenFollowing: Float = 220.0
        static let movementSpeedWhenEscaping: Float = 150.0
        // needed?
        static let appearDuration: NSTimeInterval = 0.5
        // needed?
        static let hitStateDuration: NSTimeInterval = 0.5
        
        /// The radius of the Enemy's physics body.
        static var physicsBodyRadius: CGFloat = 20.0
    }
}