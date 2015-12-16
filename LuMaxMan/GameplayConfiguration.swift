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
        static let movementSpeed: CGFloat = 210.0
    }
}